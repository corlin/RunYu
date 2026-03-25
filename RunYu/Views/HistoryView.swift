//
//  HistoryView.swift
//  RunYu
//
//  转写历史记录界面
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var history = TranscriptionHistory.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 统计栏
            HStack(spacing: 20) {
                StatBadge(title: "今日转写", value: "\(history.todayCount) 次", icon: "mic.fill", color: .blue)
                StatBadge(title: "今日字数", value: "\(history.todayWordCount) 字", icon: "character.cursor.ibeam", color: .green)
                StatBadge(title: "总记录", value: "\(history.records.count) 条", icon: "clock.arrow.circlepath", color: .orange)
                
                Spacer()
                
                if !history.records.isEmpty {
                    Button(action: { history.clearAll() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("清空")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // 历史列表
            if history.records.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("暂无转写记录")
                        .foregroundColor(.secondary)
                    Text("使用 ⌥V 开始语音输入后，记录将自动保存")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(history.records) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            // 时间和时长
                            HStack {
                                Text(record.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("·")
                                    .foregroundColor(.secondary)
                                
                                Text(formatDuration(record.duration))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                // 复制按钮
                                Button(action: {
                                    #if os(macOS)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(record.polished, forType: .string)
                                    #else
                                    UIPasteboard.general.string = record.polished
                                    #endif
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.blue)
                                .help("复制润色后文本")
                            }
                            
                            // 润色后文本
                            Text(record.polished)
                                .font(.body)
                                .lineLimit(3)
                                .textSelection(.enabled)
                            
                            // 原文（折叠显示）
                            if record.original != record.polished {
                                DisclosureGroup("原文") {
                                    Text(record.original)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textSelection(.enabled)
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        history.removeRecords(at: offsets)
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if mins > 0 {
            return "\(mins)分\(secs)秒"
        }
        return "\(secs)秒"
    }
}

// MARK: - 统计徽章
struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.caption.bold())
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
