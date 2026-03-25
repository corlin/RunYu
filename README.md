# RunYu（润语）

> 说即成文，润物无声

**RunYu（润语）** 是一款面向 macOS 和 iOS 的 AI 语音输入工具。只需自然说话，即可实时转化为高质量书面文字——自动去除口头禅、修正语法、补充标点、润色表达。

## ✨ 核心特性

- 🎤 **AI 语音输入** — 语音→文字延迟 < 1s，支持连续长时间口述
- 🧠 **智能润色** — 口语自动转化为流畅书面语，可调节润色程度
- 🌍 **多语言 + 方言** — 中英混合自动分辨，粤语/川话/沪语等 10+ 方言
- 🔒 **隐私优先** — 端侧 Whisper.cpp 推理，云端零数据留存，支持完全离线
- 📱 **Apple 生态** — macOS + iOS 原生开发，iCloud 多端同步
- 🗣️ **解放双手** — 单击激活持续监听，语音指令控制，全程免手持

## 📖 文档

- [产品需求文档 (PRD)](./PRD_RunYu.md)

## 🛠️ 技术栈

| 模块 | 技术 |
|------|------|
| 开发语言 | Swift + C/C++ |
| UI 框架 | SwiftUI + AppKit/UIKit |
| 语音识别 | Whisper.cpp (端侧) |
| AI 润色 | Core ML + MLX (端侧) / LLM API (云端) |
| 音频处理 | AVFoundation + RNNoise |
| 同步 | iCloud CloudKit |

## 📅 路线图

| 阶段 | 周期 | 目标 |
|------|------|------|
| MVP | Month 1-3 | 核心语音→文字体验跑通 |
| AI 深化 | Month 4-6 | AI 润色达到 Typeless 水准 |
| 体验增强 | Month 7-9 | 方言 + 翻译 + 低语模式 |
| 生态扩展 | Month 10-14 | API / 企业版 / watchOS / visionOS |

## 📄 License

MIT
