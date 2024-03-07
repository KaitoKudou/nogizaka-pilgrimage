//
//  UserDefaultsManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/17.
//

import Foundation

class UserDefaultsManager {
    enum Keys: String {
        case favorite = "favoriteCodes"
        case checkedIn = "checkedInCodes"
    }

    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard

    func updateList(code: String, userDefaultsKey: Keys) {
        var codes = userDefaults.stringArray(forKey: userDefaultsKey.rawValue) ?? []

        if !codes.contains(code) {
            codes.append(code)
        } else {
            if userDefaultsKey == .favorite {
                codes.removeAll { $0 == code }
            }
        }

        userDefaults.set(codes, forKey: userDefaultsKey.rawValue)
    }

    func fetchCodeList(userDefaultsKey: Keys) -> [String] {
        return userDefaults.stringArray(forKey: userDefaultsKey.rawValue) ?? []
    }

    func fetchList(userDefaultsKey: Keys) -> [PilgrimageInformation] {
        let codes = userDefaults.stringArray(forKey: userDefaultsKey.rawValue) ?? []
        return dummyPilgrimageList.filter { codes.contains($0.code) }
    }

    func isContainedInList(code: String, userDefaultsKey: Keys) -> Bool {
        let codes = userDefaults.stringArray(forKey: userDefaultsKey.rawValue) ?? []
        return codes.contains(code)
    }
}
