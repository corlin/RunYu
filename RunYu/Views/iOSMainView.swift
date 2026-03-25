//
//  iOSMainView.swift
//  RunYu
//
//  iOS 端主程序界面
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct iOSMainView: View {
    @StateObject private var viewModel = VoiceInputViewModel()
    
    var body: some View {
        TabView {
            // == 引导栏 ==
            NavigationView {
                VStack(spacing: 20) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("欢迎使用润语键盘")
                        .font(.title)
                        .bold()
                    
                    Text("为了使用语音输入并跨应用粘贴文字，\n请先前往系统设置启用键盘。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("前往「设置 > 通用 > 键盘」", systemImage: "1.circle.fill")
                        Label("添加新键盘，选择「润语」", systemImage: "2.circle.fill")
                        Label("点击润语，允许「完全访问」", systemImage: "3.circle.fill")
                            .foregroundColor(.red) // 特别提醒需要完全访问
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    
                    Button(action: {
                        #if os(iOS)
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        #endif
                    }) {
                        Text("去设置开启")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationTitle("启动引导")
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }
            
            // == 词典栏 ==
            NavigationView {
                DictionaryView()
            }
            .tabItem {
                Label("词典", systemImage: "character.book.closed")
            }
            
            // == 历史记录栏 ==
            NavigationView {
                HistoryView()
                    .navigationTitle("流转历史")
            }
            .tabItem {
                Label("历史", systemImage: "clock.arrow.circlepath")
            }
            
            // == 通用设置栏 ==
            NavigationView {
                SettingsView()
                    .navigationTitle("设置")
            }
            .tabItem {
                Label("设置", systemImage: "gear")
            }
        }
    }
}
