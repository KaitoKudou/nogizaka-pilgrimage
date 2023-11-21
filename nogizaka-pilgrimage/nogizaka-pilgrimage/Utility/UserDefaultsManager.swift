//
//  UserDefaultsManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/17.
//

import Foundation

class UserDefaultsManager {
    private enum Keys: String {
        case favorite = "favoriteCodes"
    }

    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard

    func updateFavoriteList(code: String) {
        var favoriteCodes = userDefaults.stringArray(forKey: Keys.favorite.rawValue) ?? []

        if !favoriteCodes.contains(code) {
            favoriteCodes.append(code)
        } else {
            favoriteCodes.removeAll { $0 == code }
        }

        userDefaults.set(favoriteCodes, forKey: Keys.favorite.rawValue)
    }

    func fetchFavorites() -> [PilgrimageInformation] {
        let favoriteCodes = userDefaults.stringArray(forKey: Keys.favorite.rawValue) ?? []
        let favoritePilgrimages = dummyPilgrimageList.filter { favoriteCodes.contains($0.code) }
        return favoritePilgrimages
    }

    func isFavorite(code: String) -> Bool {
        let favoriteCodes = userDefaults.stringArray(forKey: Keys.favorite.rawValue) ?? []
        return favoriteCodes.contains(code)
    }
}
