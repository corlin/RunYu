//
//  RunYuApp.swift
//  RunYu
//
//  Created by 陈永林 on 25/03/2026.
//

import SwiftUI

@main
struct RunYuApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @StateObject private var viewModel = VoiceInputViewModel()
    
    var body: some Scene {
        #if os(macOS)
        // 菜单栏常驻图标
        MenuBarExtra {
            MenuBarView(viewModel: viewModel)
        } label: {
            Image(systemName: viewModel.isListening ? "waveform.circle.fill" : "mic.circle")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(viewModel.isListening ? .green : .primary)
        }
        .menuBarExtraStyle(.window)
        
        // 设置窗口
        Window("润语设置", id: "settings") {
            SettingsView()
        }
        .defaultSize(width: 500, height: 400)
        #else
        // iOS 主界面
        WindowGroup {
            iOSMainView()
        }
        #endif
    }
}

#if os(macOS)

/// AppDelegate 处理全局热键注册和权限检查
class AppDelegate: NSObject, NSApplicationDelegate {
    var hotkeyManager: HotkeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 注册全局热键
        hotkeyManager = HotkeyManager.shared
        hotkeyManager?.register()
        
        // 请求麦克风和语音识别权限
        PermissionManager.shared.requestAllPermissions()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregister()
    }
}
#endif
