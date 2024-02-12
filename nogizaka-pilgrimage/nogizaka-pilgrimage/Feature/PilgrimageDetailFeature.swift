//
//  PilgrimageDetailFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import ComposableArchitecture

struct PilgrimageDetailFeature: Reducer {
    struct State: Equatable {
        var favoriteState: FavoriteFeature.State
        var checkInState: CheckInFeature.State
    }

    enum Action: Equatable {
        case favoriteAction(FavoriteFeature.Action)
        case checkInAction(CheckInFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .favoriteAction(let action):
                return FavoriteFeature().reduce(into: &state.favoriteState, action: action)
                    .map { Action.favoriteAction($0) }
            case .checkInAction(let action):
                return CheckInFeature().reduce(into: &state.checkInState, action: action)
                    .map { Action.checkInAction($0) }
            }
        }
    }
}
