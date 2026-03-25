//
//  TextPolisher.swift
//  RunYu
//
//  基础 AI 润色模块
//  MVP 阶段使用规则引擎去除口头禅、补充标点
//

import Foundation

class TextPolisher {
    static let shared = TextPolisher()
    
    /// 中文口头禅列表
    private let fillerWords: [String] = [
        "嗯", "啊", "呃", "额", "哦", "噢",
        "就是说", "就是", "然后呢", "然后",
        "那个", "这个",
        "对吧", "是吧", "好吧",
        "怎么说呢", "你知道吗", "我觉得吧",
        "反正", "其实吧", "基本上",
    ]
    
    /// 句末语气词（在句中可能需要保留，但重复出现需要清理）
    private let trailingFillers: [String] = [
        "啊", "呀", "吧", "呢", "嘛", "哈",
    ]
    
    private init() {}
    
    /// 润色文本
    func polish(_ text: String) -> String {
        var result = text
        
        // 1. 去除口头禅
        result = removeFillerWords(result)
        
        // 2. 去除重复词
        result = removeRepetitions(result)
        
        // 3. 清理多余空格
        result = cleanWhitespace(result)
        
        // 4. 确保基本标点
        result = ensurePunctuation(result)
        
        return result
    }
    
    /// 去除口头禅
    private func removeFillerWords(_ text: String) -> String {
        var result = text
        
        // 去除独立出现的口头禅（前后是空格或标点或开头结尾）
        for filler in fillerWords {
            // 匹配模式：口头禅前后是空格、标点或边界
            let patterns = [
                "^\\s*\(filler)\\s*",       // 句首
                "\\s+\(filler)\\s*",         // 句中（前有空格）
                "[，。！？、]\\s*\(filler)\\s*", // 标点后
            ]
            
            for pattern in patterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    result = regex.stringByReplacingMatches(
                        in: result,
                        options: [],
                        range: NSRange(result.startIndex..., in: result),
                        withTemplate: " "
                    )
                }
            }
        }
        
        return result
    }
    
    /// 去除连续重复的词
    private func removeRepetitions(_ text: String) -> String {
        var result = text
        
        // 匹配连续重复的 2-4 字词组
        if let regex = try? NSRegularExpression(pattern: "([\u{4e00}-\u{9fff}]{1,4})\\1+", options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: "$1"
            )
        }
        
        return result
    }
    
    /// 清理多余空格
    private func cleanWhitespace(_ text: String) -> String {
        var result = text
        
        // 多个空格合并为一个
        if let regex = try? NSRegularExpression(pattern: "\\s{2,}", options: []) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: " "
            )
        }
        
        // 去掉首尾空格
        result = result.trimmingCharacters(in: .whitespaces)
        
        return result
    }
    
    /// 确保句末有标点
    private func ensurePunctuation(_ text: String) -> String {
        var result = text
        
        // 如果文本不为空且末尾不是标点，加句号
        if !result.isEmpty {
            let lastChar = result.last!
            let punctuations: [Character] = ["。", "！", "？", ".", "!", "?", "，", ",", "；", ";", "：", ":"]
            if !punctuations.contains(lastChar) {
                // 判断内容是中文还是英文
                if result.range(of: "[\u{4e00}-\u{9fff}]", options: .regularExpression) != nil {
                    result += "。"
                } else {
                    result += "."
                }
            }
        }
        
        return result
    }
}
