//
//  MenuFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/28.
//

import ComposableArchitecture

struct MenuFeature: Reducer {
    struct State: Equatable {}

    enum Action: Equatable {
        case view(MenuItem)
    }

    

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.contact):
                print("お問い合わせ")
                return .none
            case .view(.termsOfUse):
                print("利用規約")
                return .none
            case .view(.privacyPolicy):
                print("プライバシーポリシー")
                return .none
            case .view(.appVersion):
                print("アプリバージョン")
                return .none
            }
        }
    }
}
