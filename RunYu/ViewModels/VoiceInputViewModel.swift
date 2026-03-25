//
//  VoiceInputViewModel.swift
//  RunYu
//
//  核心状态管理
//  协调各模块：热键 → 音频 → 识别 → 润色 → 插入
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

enum VoiceInputState {
    case idle        // 待机
    case listening   // 监听中
    case processing  // 处理中
}

@MainActor
class VoiceInputViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var state: VoiceInputState = .idle
    @Published var currentTranscription: String = ""
    @Published var polishedText: String = ""
    @Published var audioLevel: Float = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var showFloatingPanel: Bool = false
    @Published var statusMessage: String = "按 ⌥V 激活语音输入"
    
    /// 是否正在监听
    var isListening: Bool {
        state == .listening
    }
    
    // MARK: - Private
    
    private let audioCapture = AudioCaptureManager.shared
    private let speechRecognizer = SpeechRecognizer.shared
    private let textPolisher = TextPolisher.shared
    private let textInserter = TextInserter.shared
    private let history = TranscriptionHistory.shared
    
    private var durationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    /// iOS 专用的文本插入回调（键盘扩展需要使用 proxy 插入，主 App 使用剪贴板）
    var onInsertText: ((String) -> Void)?
    
    /// 语音停止指令关键词
    private let stopCommands = ["停止录入", "停止输入", "结束录入", "结束输入"]
    
    // MARK: - Init
    
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // 监听全局热键
        HotkeyManager.shared.onHotkeyPressed = { [weak self] in
            Task { @MainActor in
                self?.toggleVoiceInput()
            }
        }
        
        // 监听静默超时通知
        NotificationCenter.default.publisher(for: .voiceInputShouldStop)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopVoiceInput()
            }
            .store(in: &cancellables)
        
        // 设置音频回调
        audioCapture.onAudioBuffer = { [weak self] buffer in
            self?.speechRecognizer.appendAudioBuffer(buffer)
        }
        
        audioCapture.onAudioLevel = { [weak self] level in
            Task { @MainActor in
                self?.audioLevel = level
            }
        }
        
        // 设置识别回调
        speechRecognizer.onTranscription = { [weak self] text, isFinal in
            Task { @MainActor [weak self] in
                self?.handleTranscription(text: text, isFinal: isFinal)
            }
        }
        
        speechRecognizer.onError = { [weak self] error in
            Task { @MainActor [weak self] in
                self?.handleError(error)
            }
        }
    }
    
    // MARK: - Voice Input Control
    
    /// 切换语音输入状态
    func toggleVoiceInput() {
        switch state {
        case .idle:
            startVoiceInput()
        case .listening:
            stopVoiceInput()
        case .processing:
            break // 处理中不响应
        }
    }
    
    /// 启动语音输入
    func startVoiceInput() {
        // 检查权限
        guard PermissionManager.shared.isAccessibilityEnabled else {
            PermissionManager.shared.promptAccessibilityPermission()
            statusMessage = "⚠️ 请授权辅助功能权限后重试"
            return
        }
        
        // 重置状态
        currentTranscription = ""
        polishedText = ""
        duration = 0
        audioLevel = 0
        
        // 启动音频采集
        do {
            try audioCapture.startCapture()
        } catch {
            statusMessage = "❌ 麦克风启动失败: \(error.localizedDescription)"
            return
        }
        
        // 启动语音识别
        speechRecognizer.startRecognition()
        
        // 更新状态
        state = .listening
        showFloatingPanel = true
        statusMessage = "🎤 正在监听..."
        
        // 启动计时
        startDurationTimer()
        
        #if os(macOS)
        // 播放开始提示音
        NSSound(named: "Tink")?.play()
        #endif
    }
    
    /// 停止语音输入
    func stopVoiceInput() {
        guard state == .listening else { return }
        
        state = .processing
        statusMessage = "⏳ 处理中..."
        
        // 停止音频和识别
        audioCapture.stopCapture()
        speechRecognizer.stopRecognition()
        stopDurationTimer()
        
        // 润色并插入文本
        let finalText = currentTranscription
        if !finalText.isEmpty {
            polishedText = textPolisher.polish(finalText)
            
            #if os(macOS)
            textInserter.insertText(polishedText)
            #else
            if let handler = onInsertText {
                handler(polishedText) // 交给 KeyboardViewController 插入
            } else {
                UIPasteboard.general.string = polishedText // 默认降级复制到剪贴板
            }
            #endif
            
            // 保存到历史记录
            history.addRecord(
                original: finalText,
                polished: polishedText,
                duration: duration
            )
            
            statusMessage = "✅ 已插入 \(polishedText.count) 字"
        } else {
            statusMessage = "未检测到语音"
        }
        
        #if os(macOS)
        // 播放结束提示音
        NSSound(named: "Pop")?.play()
        
        // 延迟关闭浮动窗口
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.state = .idle
            self?.showFloatingPanel = false
            self?.statusMessage = "按 ⌥V 激活语音输入"
        }
        #else
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.state = .idle
            self?.statusMessage = "空闲"
        }
        #endif
    }
    
    // MARK: - Handlers
    
    private func handleTranscription(text: String, isFinal: Bool) {
        // 检测语音停止指令
        for command in stopCommands {
            if text.hasSuffix(command) || text.contains(command) {
                // 去掉停止指令本身
                currentTranscription = text.replacingOccurrences(of: command, with: "").trimmingCharacters(in: .whitespaces)
                print("[RunYu] 🗣️ 检测到语音指令: \(command)")
                stopVoiceInput()
                return
            }
        }
        
        currentTranscription = text
        
        if isFinal {
            stopVoiceInput()
        }
    }
    
    private func handleError(_ error: Error) {
        // 忽略取消导致的错误
        if error.localizedDescription.contains("canceled") { return }
        if (error as NSError).code == 216 { return }
        guard state == .listening else { return }
        
        print("[RunYu] ❌ 识别错误: \(error.localizedDescription)")
        statusMessage = "❌ \(error.localizedDescription)"
        
        audioCapture.stopCapture()
        stopDurationTimer()
        
        #if os(macOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.state = .idle
            self?.showFloatingPanel = false
            self?.statusMessage = "按 ⌥V 激活语音输入"
        }
        #else
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.state = .idle
            self?.statusMessage = "空闲"
        }
        #endif
    }
    
    // MARK: - Timer
    
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.duration += 0.1
            }
        }
    }
    
    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }
}
