//
//  SettingsView.swift
//  RunYu
//
//  设置页面
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SettingsView: View {
    @AppStorage("hotkeyDisplay", store: UserDefaultsManager.shared) private var hotkeyDisplay: String = "⌥V"
    @AppStorage("polishEnabled", store: UserDefaultsManager.shared) private var polishEnabled: Bool = true
    @AppStorage("autoInsert", store: UserDefaultsManager.shared) private var autoInsert: Bool = true
    @AppStorage("silenceTimeout", store: UserDefaultsManager.shared) private var silenceTimeout: Double = 30.0
    @AppStorage("language", store: UserDefaultsManager.shared) private var language: String = "zh-CN"
    
    var body: some View {
        #if os(macOS)
        TabView {
            generalSettings
                .tabItem { Label("通用", systemImage: "gear") }
            
            DictionaryView()
                .tabItem { Label("词典", systemImage: "character.book.closed") }
            
            HistoryView()
                .tabItem { Label("历史", systemImage: "clock.arrow.circlepath") }
            
            permissionsSettings
                .tabItem { Label("权限", systemImage: "lock.shield") }
            
            aboutSettings
                .tabItem { Label("关于", systemImage: "info.circle") }
        }
        .frame(minWidth: 500, minHeight: 400)
        #else
        Form {
            Section("通用") {
                NavigationLink(destination: generalSettings.navigationTitle("通用")) {
                    Label("通用", systemImage: "gear")
                }
            }
            
            Section("权限") {
                NavigationLink(destination: permissionsSettings.navigationTitle("权限")) {
                    Label("权限", systemImage: "lock.shield")
                }
            }
            
            Section("关于") {
                NavigationLink(destination: aboutSettings.navigationTitle("关于")) {
                    Label("关于", systemImage: "info.circle")
                }
            }
        }
        #endif
    }
    
    // MARK: - Subviews
    
    private var generalSettings: some View {
        Form {
            #if os(macOS)
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
            #endif
            
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
            
            Section("语音指令") {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.blue)
                    Text("说「停止录入」可语音停止输入")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private var permissionsSettings: some View {
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
                    #if os(macOS)
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
                    #else
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    #endif
                }
            }
        }
        .formStyle(.grouped)
    }
    
    private var aboutSettings: some View {
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
