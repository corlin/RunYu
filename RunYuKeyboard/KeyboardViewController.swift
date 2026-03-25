//
//  KeyboardViewController.swift
//  RunYuKeyboard
//
//  Created by 陈永林 on 25/03/2026.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    let viewModel = VoiceInputViewModel()
    private var hostingController: UIHostingController<KeyboardView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 挂载数据回调：当录制完成润色后，键盘自动向文本框打字
        viewModel.onInsertText = { [weak self] text in
            self?.textDocumentProxy.insertText(text + " ")
        }
        
        // 挂载 SwiftUI 
        let swiftUIView = KeyboardView(viewModel: viewModel, inputViewController: self)
        let hosting = UIHostingController(rootView: swiftUIView)
        
        self.addChild(hosting)
        self.view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        // 让 SwiftUI 清空背景，让输入法系统决定背景色
        hosting.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hosting.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            hosting.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            hosting.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.hostingController = hosting
        
        // 约定高度，系统会尽量满足这个键盘高度
        self.view.heightAnchor.constraint(equalToConstant: 230).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 键盘收起时强制停止录音，防止后台占用麦克风
        if viewModel.isListening {
            viewModel.stopVoiceInput()
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {}
    
    override func textDidChange(_ textInput: UITextInput?) {}

}
