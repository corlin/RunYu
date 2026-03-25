//
//  TranscriptionHistory.swift
//  RunYu
//
//  转写历史记录管理器
//  保存每次语音输入的原文和润色后文本
//

import SwiftUI
import Combine

class TranscriptionHistory: ObservableObject {
    static let shared = TranscriptionHistory()
    
    private let storageKey = "runyu_transcription_history"
    private let maxEntries = 100
    
    @Published var records: [TranscriptionRecord] = []
    
    private init() {
        loadRecords()
    }
    
    /// 添加一条转写记录
    func addRecord(original: String, polished: String, duration: TimeInterval, language: String = "zh-CN") {
        let record = TranscriptionRecord(
            original: original,
            polished: polished,
            duration: duration,
            language: language
        )
        
        records.insert(record, at: 0) // 最新的在前
        
        // 限制最大数量
        if records.count > maxEntries {
            records = Array(records.prefix(maxEntries))
        }
        
        saveRecords()
    }
    
    /// 删除记录
    func removeRecords(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecords()
    }
    
    /// 清空全部历史
    func clearAll() {
        records.removeAll()
        saveRecords()
    }
    
    /// 今日转写字数
    var todayWordCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return records
            .filter { $0.timestamp >= today }
            .reduce(0) { $0 + $1.polished.count }
    }
    
    /// 今日转写次数
    var todayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return records.filter { $0.timestamp >= today }.count
    }
    
    // MARK: - 持久化
    
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaultsManager.shared.set(data, forKey: storageKey)
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaultsManager.shared.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([TranscriptionRecord].self, from: data) {
            records = saved
        }
    }
}

// MARK: - 转写记录模型
struct TranscriptionRecord: Codable, Identifiable {
    let id: UUID
    let original: String    // 原始转写
    let polished: String    // 润色后
    let duration: TimeInterval // 录音时长
    let language: String    // 识别语言
    let timestamp: Date     // 时间戳
    
    init(original: String, polished: String, duration: TimeInterval, language: String) {
        self.id = UUID()
        self.original = original
        self.polished = polished
        self.duration = duration
        self.language = language
        self.timestamp = Date()
    }
}
