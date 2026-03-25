//
//  ContentView.swift
//  RunYu
//
//  浮动预览窗 — 实时显示语音转写结果
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: VoiceInputViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部状态栏
            HStack {
                // 语音状态指示
                Circle()
                    .fill(viewModel.isListening ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(viewModel.isListening ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isListening)
                
                Text(viewModel.isListening ? "正在监听" : "待机")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 录音时长
                if viewModel.isListening {
                    Text(formatDuration(viewModel.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                // 音频波形
                if viewModel.isListening {
                    AudioWaveView(level: viewModel.audioLevel)
                        .frame(width: 40, height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // 转写内容区
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if viewModel.currentTranscription.isEmpty {
                        Text("开始说话...")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Text(viewModel.currentTranscription)
                            .font(.body)
                            .lineSpacing(4)
                            .textSelection(.enabled)
                    }
                    
                    // 如果有润色结果，显示对比
                    if !viewModel.polishedText.isEmpty && viewModel.polishedText != viewModel.currentTranscription {
                        Divider()
                        
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                            Text("润色后")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text(viewModel.polishedText)
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 100, maxHeight: 200)
            
            Divider()
            
            // 底部操作栏
            HStack {
                // 状态消息
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                // 停止按钮
                if viewModel.isListening {
                    Button(action: { viewModel.stopVoiceInput() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "stop.circle.fill")
                            Text("停止")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .controlSize(.small)
                }
                
                // 复制按钮
                if !viewModel.polishedText.isEmpty {
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(viewModel.polishedText, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("复制润色后的文本")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .frame(width: 380)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - 音频波形动画视图
struct AudioWaveView: View {
    let level: Float
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.green)
                    .frame(width: 3, height: barHeight(for: i))
                    .animation(.easeInOut(duration: 0.15), value: level)
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let base: CGFloat = 3
        let maxHeight: CGFloat = 16
        let variation = sin(Double(index) * 1.2 + Double(level) * 10) * 0.3 + 0.7
        return base + CGFloat(Double(level) * variation) * (maxHeight - base)
    }
}
