//
//  TextInserter.swift
//  RunYu
//
//  文本插入模块
//  将转写结果插入到当前光标位置
//

import Foundation

#if os(macOS)
import AppKit

class TextInserter {
    static let shared = TextInserter()
    
    private init() {}
    
    /// 将文本插入到当前活跃应用的光标位置
    /// 使用剪贴板 + 模拟 ⌘V 的方式
    func insertText(_ text: String) {
        guard !text.isEmpty else { return }
        
        let pasteboard = NSPasteboard.general
        
        // 1. 保存当前剪贴板内容
        let savedItems = pasteboard.pasteboardItems?.compactMap { item -> (String, String)? in
            for type in item.types {
                if let data = item.string(forType: type) {
                    return (type.rawValue, data)
                }
            }
            return nil
        }
        
        // 2. 将要插入的文本放入剪贴板
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // 3. 模拟 ⌘V 粘贴
        simulatePaste()
        
        // 4. 延迟恢复剪贴板内容
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let saved = savedItems, !saved.isEmpty {
                pasteboard.clearContents()
                for (typeRaw, data) in saved {
                    pasteboard.setString(data, forType: NSPasteboard.PasteboardType(typeRaw))
                }
            }
        }
        
        print("[RunYu] 📋 文本已插入（\(text.count) 字）")
    }
    
    /// 模拟 ⌘V 粘贴操作
    private func simulatePaste() {
        // 创建 keyDown 事件 (⌘V)
        let keyVCode: CGKeyCode = 9 // V 键的 keyCode
        
        if let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyVCode, keyDown: true) {
            keyDown.flags = .maskCommand
            keyDown.post(tap: .cgAnnotatedSessionEventTap)
        }
        
        // 创建 keyUp 事件
        if let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyVCode, keyDown: false) {
            keyUp.flags = .maskCommand
            keyUp.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}
#else
class TextInserter {
    static let shared = TextInserter()
    func insertText(_ text: String) {}
}
#endif
