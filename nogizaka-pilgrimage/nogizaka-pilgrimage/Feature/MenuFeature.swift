//
//  MenuFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/28.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {}

    enum Action: Equatable {
        case view(MenuItem)
    }

    @Dependency(\.safari) var safari

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.contact):
                let url = URL(string: "https://forms.gle/dVsUCgo6GkoLUqxA7")!
                return .run { _ in await safari(url) }
            case .view(.termsOfUse):
                let url = URL(string: "https://sites.google.com/view/nogi-jyunrei/terms")!
                return .run { _ in await safari(url) }
            case .view(.privacyPolicy):
                let url = URL(string: "https://sites.google.com/view/nogi-jyunrei/privacy-policy")!
                return .run { _ in await safari(url) }
            case .view(.appVersion):
                return .none
            }
        }
    }
}
