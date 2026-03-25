//
//  DictionaryView.swift
//  RunYu
//
//  个人词典管理界面
//

import SwiftUI

struct DictionaryView: View {
    @ObservedObject var dictionary = DictionaryManager.shared
    @State private var newWord = ""
    @State private var newReplacement = ""
    @State private var selectedCategory = "通用"
    
    private let categories = ["通用", "技术", "人名", "公司", "行业术语"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 添加新词条
            HStack(spacing: 8) {
                TextField("词汇", text: $newWord)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 100)
                
                TextField("替换为（可选）", text: $newReplacement)
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: 100)
                
                Picker("", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                .frame(width: 90)
                
                Button(action: addWord) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .disabled(newWord.isEmpty)
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
            .padding(12)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // 词条列表
            if dictionary.entries.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "character.book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("词典为空")
                        .foregroundColor(.secondary)
                    Text("添加专有名词、术语，提升识别准确率")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(groupedEntries.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)) {
                            ForEach(groupedEntries[category] ?? []) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.word)
                                            .font(.body)
                                        if let replacement = entry.replacement, !replacement.isEmpty {
                                            Text("→ \(replacement)")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(entry.createdAt, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onDelete { offsets in
                                deleteEntries(in: category, at: offsets)
                            }
                        }
                    }
                }
            }
            
            // 底部统计
            HStack {
                Text("共 \(dictionary.entries.count) 个词条")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
        }
    }
    
    private var groupedEntries: [String: [DictionaryEntry]] {
        Dictionary(grouping: dictionary.entries, by: { $0.category })
    }
    
    private func addWord() {
        dictionary.addEntry(
            word: newWord,
            replacement: newReplacement.isEmpty ? nil : newReplacement,
            category: selectedCategory
        )
        newWord = ""
        newReplacement = ""
    }
    
    private func deleteEntries(in category: String, at offsets: IndexSet) {
        guard let entries = groupedEntries[category] else { return }
        for index in offsets {
            dictionary.removeEntry(word: entries[index].word)
        }
    }
}
