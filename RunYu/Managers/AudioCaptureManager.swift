//
//  AudioCaptureManager.swift
//  RunYu
//
//  音频采集管理器
//  使用 AVAudioEngine 捕获麦克风音频
//

import AVFoundation

class AudioCaptureManager {
    static let shared = AudioCaptureManager()
    
    private let audioEngine = AVAudioEngine()
    private var isCapturing = false
    
    /// 音频缓冲区回调（用于语音识别）
    var onAudioBuffer: ((AVAudioPCMBuffer) -> Void)?
    
    /// 音频电平回调（用于 UI 波形动画）
    var onAudioLevel: ((Float) -> Void)?
    
    private init() {}
    
    /// 开始音频采集
    func startCapture() throws {
        guard !isCapturing else { return }
        
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // 安装音频 tap，捕获音频缓冲区
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            // 传递给语音识别
            self?.onAudioBuffer?(buffer)
            
            // 计算音频电平（用于 UI）
            self?.calculateAudioLevel(buffer: buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        isCapturing = true
        print("[RunYu] 🎤 音频采集已启动")
    }
    
    /// 停止音频采集
    func stopCapture() {
        guard isCapturing else { return }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isCapturing = false
        
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
        
        print("[RunYu] 🎤 音频采集已停止")
    }
    
    /// 计算音频电平（RMS）
    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))
        
        // 转换为 0-1 范围的音量值
        let level = min(max(rms * 5.0, 0), 1.0)
        
        DispatchQueue.main.async { [weak self] in
            self?.onAudioLevel?(level)
        }
    }
}
