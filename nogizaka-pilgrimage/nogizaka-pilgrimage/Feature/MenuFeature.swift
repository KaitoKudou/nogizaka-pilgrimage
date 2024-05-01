//
//  MenuFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/28.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {
        var appVersion: String = ""
        var path = StackState<Path.State>()
    }

    enum Action {
        case onAppear
        case view(MenuItem)
        case path(StackAction<Path.State, Path.Action>)
    }

    @Dependency(\.safari) var safari
    @Dependency(\.buildClient) var buildClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = buildClient.appVersion()
                return .none
            case .view(.aboutDeveloper):
                let url = URL(string: "https://twitter.com/kudokai00")!
                return .run { _ in await safari(url) }
            case .view(.contact):
                let url = URL(string: "https://forms.gle/dVsUCgo6GkoLUqxA7")!
                return .run { _ in await safari(url) }
            case .view(.termsOfUse):
                let url = URL(string: "https://sites.google.com/view/nogi-jyunrei/terms")!
                return .run { _ in await safari(url) }
            case .view(.openSourceLicense):
                state.path.append(.openSourceLicense)
                return .none
            case .view(.iconLicense):
                state.path.append(.iconLicense)
                return .none
            case .view(.privacyPolicy):
                let url = URL(string: "https://sites.google.com/view/nogi-jyunrei/privacy-policy")!
                return .run { _ in await safari(url) }
            case .view(.appVersion):
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension MenuFeature {
    @Reducer(state: .equatable)
    public enum Path {
        case openSourceLicense
        case iconLicense
    }
}
