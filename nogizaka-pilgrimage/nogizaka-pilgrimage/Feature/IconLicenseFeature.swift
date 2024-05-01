//
//  IconLicenseFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import ComposableArchitecture
import Foundation

@Reducer
struct IconLicenseFeature {
    struct State: Equatable {}

    enum Action {
        case icons8LinkTapped
    }

    @Dependency(\.safari) var safari

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .icons8LinkTapped:
                let url = URL(string: "https://icons8.com")!
                return .run { _ in await safari(url) }
            }
        }
    }
}
