//
//  HotkeyManager.swift
//  RunYu
//
//  全局热键管理器
//  监听 ⌥+V (Option+V) 切换语音输入状态
//

import SwiftUI

#if os(macOS)
import Carbon
import AppKit

class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    /// 热键触发时的回调
    var onHotkeyPressed: (() -> Void)?
    
    private init() {}
    
    /// 注册全局热键监听
    func register() {
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("[RunYu] ⚠️ 无法创建全局事件监听，请检查辅助功能权限")
            print("[RunYu] 请前往: 系统设置 → 隐私与安全性 → 辅助功能，添加 RunYu")
            return
        }
        
        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("[RunYu] ✅ 全局热键已注册 (⌥+V)")
        }
    }
    
    /// 注销全局热键
    func unregister() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        print("[RunYu] 全局热键已注销")
    }
    
    /// 处理键盘事件
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // 检查事件类型
        guard type == .keyDown else {
            return Unmanaged.passRetained(event)
        }
        
        // 获取按键信息
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // ⌥+V: keyCode 9 = V, flags 包含 .maskAlternate
        if keyCode == 9 && flags.contains(.maskAlternate) {
            // 在主线程触发回调
            DispatchQueue.main.async { [weak self] in
                self?.onHotkeyPressed?()
            }
            // 吞掉该事件，不传递给其他应用
            return nil
        }
        
        return Unmanaged.passRetained(event)
    }
}
#else
class HotkeyManager {
    static let shared = HotkeyManager()
    var onHotkeyPressed: (() -> Void)?
    private init() {}
    func register() {}
    func unregister() {}
}
#endif
