//
//  ReadableContentGuideModifier.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2025/09/29.
//

import SwiftUI

/// SwiftUI で UIKit の `readableContentGuide` を利用して
/// iPhone / iPad 双方で「読みやすい文字幅」にレイアウトを収めるためのモディファイア
///
/// 一度だけ制約を張り、後続は `rootView` を差し替えることで SwiftUI の再描画サイクルを正しく受け取る
private struct ReadableContentContainer<Content: View>: UIViewRepresentable {
    final class ContainerView: UIView {
        private(set) var hostingController: UIHostingController<Content>

        init(content: Content) {
            hostingController = UIHostingController(rootView: content)
            super.init(frame: .zero)
            hostingController.view.backgroundColor = .clear
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(hostingController.view)
            // readableContentGuide を使って左右を制約
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        func update(content: Content) {
            // 状態更新を反映させるため rootView を都度差し替える
            hostingController.rootView = content
        }
    }

    let content: Content

    func makeUIView(context: Context) -> ContainerView {
        ContainerView(content: content)
    }

    func updateUIView(_ uiView: ContainerView, context: Context) {
        uiView.update(content: content)
    }
}

struct ReadableContentGuideModifier: ViewModifier {
    func body(content: Content) -> some View {
        ReadableContentContainer(content: content)
    }
}

extension View {
    /// UIKit の `readableContentGuide` によるレイアウト制約を適用
    /// - Returns: 読みやすい幅に制約された View
    func readableContentGuide() -> some View {
        modifier(ReadableContentGuideModifier())
    }
}
