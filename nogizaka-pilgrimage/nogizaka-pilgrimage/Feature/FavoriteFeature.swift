//
//  FavoriteFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/17.
//

import ComposableArchitecture

struct FavoriteFeature: Reducer {
    struct State: Equatable {
        var favoritePilgrimages: [PilgrimageInformation] = []
        var isFavorite: Bool = false
    }

    enum Action: Equatable {
        case fetchFavorites
        case updateFavoriteList(PilgrimageInformation)
        case toggleFavorite(PilgrimageInformation)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchFavorites:
                state.favoritePilgrimages = UserDefaultsManager.shared.fetchList(userDefaultsKey: .favorite)
                return .none
            case let .updateFavoriteList(pilgrimage):
                UserDefaultsManager.shared.updateList(code: pilgrimage.code, userDefaultsKey: .favorite)
                state.favoritePilgrimages = UserDefaultsManager.shared.fetchList(userDefaultsKey: .favorite)
                return .none
            case let .toggleFavorite(pilgrimage):
                state.isFavorite = UserDefaultsManager.shared.isContainedInList(code: pilgrimage.code, userDefaultsKey: .favorite)
                return .none
            }
        }
    }
}
