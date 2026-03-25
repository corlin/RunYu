//
//  DictionaryManager.swift
//  RunYu
//
//  个人词典管理器
//  管理用户自定义术语，持久化到 UserDefaults
//

import SwiftUI
import Combine

class DictionaryManager: ObservableObject {
    static let shared = DictionaryManager()
    
    private let storageKey = "runyu_personal_dictionary"
    
    /// 个人词典（拼音/缩写 → 正确词汇）
    @Published var entries: [DictionaryEntry] = []
    
    private init() {
        loadEntries()
    }
    
    // MARK: - CRUD
    
    /// 添加词条
    func addEntry(word: String, replacement: String? = nil, category: String = "通用") {
        let entry = DictionaryEntry(
            word: word,
            replacement: replacement,
            category: category
        )
        
        // 避免重复
        guard !entries.contains(where: { $0.word == word }) else { return }
        
        entries.append(entry)
        saveEntries()
        print("[RunYu] 📖 词典添加: \(word)")
    }
    
    /// 删除词条
    func removeEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    /// 删除指定词条
    func removeEntry(word: String) {
        entries.removeAll { $0.word == word }
        saveEntries()
    }
    
    /// 批量导入
    func importWords(_ words: [String], category: String = "通用") {
        for word in words {
            addEntry(word: word, category: category)
        }
    }
    
    // MARK: - 查询
    
    /// 检查词典是否包含某个词
    func contains(_ word: String) -> Bool {
        entries.contains { $0.word == word || $0.replacement == word }
    }
    
    /// 获取替换词（如果有）
    func replacement(for word: String) -> String? {
        entries.first { $0.word == word }?.replacement
    }
    
    /// 获取所有词汇列表（用于语音识别 hint）
    var allWords: [String] {
        entries.map { $0.word }
    }
    
    // MARK: - 持久化
    
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([DictionaryEntry].self, from: data) {
            entries = saved
        }
    }
}

// MARK: - 词典条目模型
struct DictionaryEntry: Codable, Identifiable, Hashable {
    let id: UUID
    var word: String          // 词汇
    var replacement: String?  // 替换为（可选）
    var category: String      // 分类
    var createdAt: Date       // 创建时间
    
    init(word: String, replacement: String? = nil, category: String = "通用") {
        self.id = UUID()
        self.word = word
        self.replacement = replacement
        self.category = category
        self.createdAt = Date()
    }
}
