//
//  MenuFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/28.
//

import ComposableArchitecture
import Foundation

struct MenuFeature: Reducer {
    struct State: Equatable {}

    enum Action: Equatable {
        case view(MenuItem)
    }

    @Dependency(\.safari) var safari

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.contact):
                // TODO: お問い合わせリンクに差し替え
                let url = URL(string: "https://www.apple.com")!
                return .run { _ in await safari(url) }
            case .view(.termsOfUse):
                // TODO: 利用規約リンクに差し替え
                let url = URL(string: "https://www.google.com")!
                return .run { _ in await safari(url) }
            case .view(.privacyPolicy):
                // TODO: プライバシーポリシーリンクに差し替え
                let url = URL(string: "https://github.com/KaitoKudou")!
                return .run { _ in await safari(url) }
            case .view(.appVersion):
                return .none
            }
        }
    }
}
