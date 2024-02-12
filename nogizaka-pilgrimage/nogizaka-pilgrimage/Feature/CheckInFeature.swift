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
        var distance: Double = 0.0
        var isCheckedIn: Bool = false
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
            case (.addCheckInList, .addCheckInList):
                return true
            default:
                return false
            }
        }
        
        case calculateDistance(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D)
        case addCheckInList
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .calculateDistance(let userCoordinate, let pilgrimageCoordinate):
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)

                state.distance = userLocation.distance(from: pilgrimageLocation)
                return .none
            case .addCheckInList:
                print("チェックイン済みのリストに聖地を追加")
                return .none
            }
        }
    }
}
