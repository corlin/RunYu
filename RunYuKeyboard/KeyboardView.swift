//
//  KeyboardView.swift
//  RunYuKeyboard
//
//  键盘扩展 SwiftUI 主界面
//

import SwiftUI
import UIKit

struct KeyboardView: View {
    @ObservedObject var viewModel: VoiceInputViewModel
    
    // 宿主 Controller，用于触发输入法切换等 UIKit API
    weak var inputViewController: UIInputViewController?
    
    var body: some View {
        VStack(spacing: 8) {
            // == 状态提示区 ==
            HStack {
                if viewModel.isListening {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .scaleEffect(viewModel.isListening ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isListening)
                    Text("正在倾听...")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.duration))秒")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                } else if viewModel.state == .processing {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("AI 润色中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    Text("准备就绪")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // == 实时转写区 ==
            ScrollView {
                VStack(alignment: .leading) {
                    Text(viewModel.currentTranscription.isEmpty ? "点击下方麦克风开始说话" : viewModel.currentTranscription)
                        .font(.body)
                        .foregroundColor(viewModel.currentTranscription.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 60)
            
            Divider()
            
            // == 操作区 ==
            HStack {
                // 地球键（切换输入法）
                if inputViewController?.needsInputModeSwitchKey ?? true {
                    Button(action: {
                        inputViewController?.advanceToNextInputMode()
                    }) {
                        Image(systemName: "globe")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // 全面屏底部自带切换键，这里用透明占位保持对称
                    Color.clear.frame(width: 44, height: 44)
                }
                
                Spacer()
                
                // 核心麦克风按钮
                Button(action: {
                    if viewModel.isListening {
                        viewModel.stopVoiceInput()
                    } else {
                        viewModel.startVoiceInput()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isListening ? Color.red : Color.blue)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 4)
                        
                        Image(systemName: viewModel.isListening ? "stop.fill" : "mic.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.state == .processing)
                
                Spacer()
                
                // 删除按键 (回退键)
                Button(action: {
                    inputViewController?.textDocumentProxy.deleteBackward()
                }) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color("KeyboardBackground", bundle: nil)) // 依赖系统键盘背景色或系统默认
    }
}
