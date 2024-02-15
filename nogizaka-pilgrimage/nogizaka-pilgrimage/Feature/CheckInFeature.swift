//
//  CheckInFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import ComposableArchitecture
import CoreLocation

struct CheckInFeature: Reducer {
    struct State: Equatable {
        var distance: Double = 0.0 // 現在地から聖地までの距離
        var hasCheckedIn: Bool = true // チェックインしているかどうか
        var checkedInPilgrimages: [PilgrimageInformation] = []
    }

    enum Action: Equatable {
        static func == (lhs: CheckInFeature.Action, rhs: CheckInFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.calculateDistance(lhsUser, lhsPilgrimage), .calculateDistance(rhsUser, rhsPilgrimage)):
                // CLLocationCoordinate2Dを比較する
                return lhsUser.latitude == rhsUser.latitude &&
                lhsUser.longitude == rhsUser.longitude &&
                lhsPilgrimage.latitude == rhsPilgrimage.latitude &&
                lhsPilgrimage.longitude == rhsPilgrimage.longitude
            case (.addCheckedInList, .addCheckedInList):
                return true
            case (.fetchCheckedInList, .fetchCheckedInList):
                return true
            case (.verifyCheckedIn(pilgrimage: _), .verifyCheckedIn(pilgrimage: _)):
                return true
            default:
                return false
            }
        }

        case calculateDistance(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D)
        case addCheckedInList(pilgrimage: PilgrimageInformation)
        case fetchCheckedInList
        case verifyCheckedIn(pilgrimage: PilgrimageInformation)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .calculateDistance(let userCoordinate, let pilgrimageCoordinate):
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)

                state.distance = userLocation.distance(from: pilgrimageLocation)
                return .none
            case .addCheckedInList(let pilgrimage):
                UserDefaultsManager.shared.updateList(code: pilgrimage.code, userDefaultsKey: .checkedIn)
                state.checkedInPilgrimages = UserDefaultsManager.shared.fetchList(userDefaultsKey: .checkedIn)
                return .none
            case .fetchCheckedInList:
                state.checkedInPilgrimages = UserDefaultsManager.shared.fetchList(userDefaultsKey: .checkedIn)
                return .none
            case .verifyCheckedIn(let pilgrimage):
                state.hasCheckedIn = UserDefaultsManager.shared.isContainedInList(code: pilgrimage.code, userDefaultsKey: .checkedIn)
                return .none
            }
        }
    }
}
