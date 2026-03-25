//
//  SpeechRecognizer.swift
//  RunYu
//
//  语音识别管理器
//  使用 Apple Speech Framework 进行实时流式识别
//

import Speech
import AVFoundation

class SpeechRecognizer {
    static let shared = SpeechRecognizer()
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isRunning = false
    
    /// 实时转写结果回调（partial + final）
    var onTranscription: ((String, Bool) -> Void)? // (text, isFinal)
    
    /// 错误回调
    var onError: ((Error) -> Void)?
    
    /// 静默超时（秒）
    var silenceTimeout: TimeInterval = 30.0
    private var silenceTimer: Timer?
    
    private init() {
        // 默认中文识别
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    }
    
    /// 开始识别
    func startRecognition() {
        guard !isRunning else { return }
        // 取消之前的任务
        stopRecognition(silent: true)
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("[RunYu] ⚠️ 语音识别不可用")
            return
        }
        
        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let request = recognitionRequest else { return }
        
        // 启用实时 partial results
        request.shouldReportPartialResults = true
        isRunning = true
        
        // 如果支持，启用端侧识别
        if #available(macOS 13, iOS 16, *) {
            request.requiresOnDeviceRecognition = false // 先用在线模式保证质量
        }
        
        // 开始识别任务
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                let isFinal = result.isFinal
                
                DispatchQueue.main.async {
                    self.onTranscription?(text, isFinal)
                }
                
                // 重置静默计时器
                self.resetSilenceTimer()
                
                if isFinal {
                    self.stopRecognition(silent: false)
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.onError?(error)
                }
                self.stopRecognition(silent: false)
            }
        }
        
        // 启动静默计时器
        resetSilenceTimer()
        
        print("[RunYu] 🧠 语音识别已启动")
    }
    
    /// 追加音频缓冲区
    func appendAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        recognitionRequest?.append(buffer)
    }
    
    /// 停止识别
    func stopRecognition(silent: Bool = false) {
        guard isRunning else { return }
        isRunning = false
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        print("[RunYu] 🧠 语音识别已停止")
    }
    
    /// 重置静默计时器
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            print("[RunYu] ⏱️ 静默超时，自动停止")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .voiceInputShouldStop, object: nil)
            }
        }
    }
}

// MARK: - 通知名称
extension Notification.Name {
    static let voiceInputShouldStop = Notification.Name("voiceInputShouldStop")
    static let voiceInputToggle = Notification.Name("voiceInputToggle")
}
