//
//  SettingsView.swift
//  RunYu
//
//  设置页面
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: VoiceInputViewModel
    
    @AppStorage("hotkeyDisplay") private var hotkeyDisplay: String = "⌥V"
    @AppStorage("polishEnabled") private var polishEnabled: Bool = true
    @AppStorage("autoInsert") private var autoInsert: Bool = true
    @AppStorage("silenceTimeout") private var silenceTimeout: Double = 30.0
    @AppStorage("language") private var language: String = "zh-CN"
    
    var body: some View {
        TabView {
            // 通用设置
            Form {
                Section("快捷键") {
                    HStack {
                        Text("语音输入切换")
                        Spacer()
                        Text(hotkeyDisplay)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(6)
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                Section("语音识别") {
                    Picker("识别语言", selection: $language) {
                        Text("中文（普通话）").tag("zh-CN")
                        Text("英文").tag("en-US")
                        Text("日文").tag("ja-JP")
                        Text("粤语").tag("zh-HK")
                    }
                    
                    HStack {
                        Text("静默超时")
                        Slider(value: $silenceTimeout, in: 10...120, step: 5)
                        Text("\(Int(silenceTimeout))秒")
                            .frame(width: 40)
                    }
                }
                
                Section("文本处理") {
                    Toggle("启用 AI 润色", isOn: $polishEnabled)
                    Toggle("自动插入到光标位置", isOn: $autoInsert)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("通用", systemImage: "gear")
            }
            
            // 权限状态
            Form {
                Section("权限状态") {
                    PermissionRow(
                        title: "麦克风",
                        icon: "mic.fill",
                        isGranted: true // TODO: 实时检查
                    )
                    
                    PermissionRow(
                        title: "语音识别",
                        icon: "waveform",
                        isGranted: true // TODO: 实时检查
                    )
                    
                    PermissionRow(
                        title: "辅助功能",
                        icon: "hand.raised.fill",
                        isGranted: PermissionManager.shared.isAccessibilityEnabled
                    )
                }
                
                Section {
                    Button("打开系统隐私设置") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("权限", systemImage: "lock.shield")
            }
            
            // 关于
            VStack(spacing: 16) {
                Spacer()
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text("润语 RunYu")
                    .font(.title.bold())
                
                Text("说即成文，润物无声")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("版本 1.0.0 (MVP)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .tabItem {
                Label("关于", systemImage: "info.circle")
            }
        }
        .frame(minWidth: 450, minHeight: 350)
    }
}

// MARK: - 权限状态行
struct PermissionRow: View {
    let title: String
    let icon: String
    let isGranted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isGranted ? .green : .orange)
            
            Text(isGranted ? "已授权" : "未授权")
                .font(.caption)
                .foregroundColor(isGranted ? .green : .orange)
        }
    }
}
