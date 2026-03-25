//
//  PermissionManager.swift
//  RunYu
//
//  权限管理器
//  统一请求和检查所需系统权限
//

import AVFoundation
import Speech

class PermissionManager {
    static let shared = PermissionManager()
    
    private init() {}
    
    /// 请求所有必要权限
    func requestAllPermissions() {
        requestMicrophonePermission()
        requestSpeechRecognitionPermission()
    }
    
    /// 请求麦克风权限
    func requestMicrophonePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    print("[RunYu] ✅ 麦克风权限已授权")
                } else {
                    print("[RunYu] ❌ 麦克风权限被拒绝")
                }
            }
        case .authorized:
            print("[RunYu] ✅ 麦克风权限已授权")
        case .denied, .restricted:
            print("[RunYu] ❌ 麦克风权限被拒绝，请前往系统设置开启")
        @unknown default:
            break
        }
    }
    
    /// 请求语音识别权限
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("[RunYu] ✅ 语音识别权限已授权")
            case .denied:
                print("[RunYu] ❌ 语音识别权限被拒绝")
            case .restricted:
                print("[RunYu] ❌ 语音识别权限受限")
            case .notDetermined:
                print("[RunYu] ⏳ 语音识别权限未确定")
            @unknown default:
                break
            }
        }
    }
    
    /// 检查辅助功能权限（对于全局热键和文本插入）
    var isAccessibilityEnabled: Bool {
        AXIsProcessTrusted()
    }
    
    /// 提示用户开启辅助功能权限
    func promptAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
