//
//  MenuBarView.swift
//  RunYu
//
//  菜单栏弹出面板视图
//

import SwiftUI

#if os(macOS)
struct MenuBarView: View {
    @ObservedObject var viewModel: VoiceInputViewModel
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // 头部：应用名 + 状态
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.isListening ? .green : .blue)
                    .symbolEffect(.pulse, isActive: viewModel.isListening)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("润语 RunYu")
                        .font(.headline)
                    Text(viewModel.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 今日统计
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(TranscriptionHistory.shared.todayCount) 次")
                        .font(.caption.bold())
                    Text("\(TranscriptionHistory.shared.todayWordCount) 字")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            
            Divider()
            
            // 语音输入控制
            VStack(spacing: 12) {
                // 大按钮 — 激活/停止语音输入
                Button(action: { viewModel.toggleVoiceInput() }) {
                    HStack {
                        Image(systemName: viewModel.isListening ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title2)
                        Text(viewModel.isListening ? "停止录入" : "开始语音输入")
                            .font(.body.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(viewModel.isListening ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                // 快捷键和语音指令提示
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "keyboard")
                            .foregroundColor(.secondary)
                        Text("⌥V")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(.secondary)
                        Text("\"停止录入\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 实时转写预览
                if viewModel.isListening || !viewModel.currentTranscription.isEmpty {
                    ContentView(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            
            Divider()
            
            // 底部操作
            VStack(spacing: 4) {
                Button(action: {
                    NSApp.activate(ignoringOtherApps: true)
                    DispatchQueue.main.async {
                        openWindow(id: "settings")
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("设置")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                Divider()
                
                Button(action: { NSApp.terminate(nil) }) {
                    HStack {
                        Image(systemName: "power")
                        Text("退出润语")
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .padding(8)
        }
        .frame(width: 360)
    }
}
#endif
