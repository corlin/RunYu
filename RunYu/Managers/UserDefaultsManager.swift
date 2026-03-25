//
//  UserDefaultsManager.swift
//  RunYu
//
//  跨进程 UserDefaults 共享管理器
//  支持主 App 和 Keyboard Extension 互通数据
//

import Foundation

struct UserDefaultsManager {
    /// App Group 标识符（需在苹果开发者后台和 Xcode Signing & Capabilities 中配置）
    static let appGroupIdentifier = "group.cn.corlin.RunYu.shared"
    
    /// 全局共享的 UserDefaults 实例
    /// 注：如果模拟器/真机上 App Group 未正确配置，将自动降级为 `UserDefaults.standard`
    static var shared: UserDefaults {
        #if os(macOS)
        // macOS 端关闭了 App Sandbox 以支持全局热键和输入注入
        // 并在单应用程序内运行，不需要 App Group 共享，直接使用 standard
        return UserDefaults.standard
        #else
        return UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        #endif
    }
}
