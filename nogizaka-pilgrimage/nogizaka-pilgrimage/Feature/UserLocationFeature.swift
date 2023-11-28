//
//  UserLocationFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/22.
//

import CoreLocation
import ComposableArchitecture
import MapKit

struct UserLocationFeature: Reducer {
    struct State: Equatable {
        var location: CLLocation?
        var isLocationPermissionDenied: Bool = false
        @PresentationState var alert: AlertState<Action.Alert>?

        static func == (lhs: UserLocationFeature.State, rhs: UserLocationFeature.State) -> Bool {
            return lhs.location == rhs.location &&
            lhs.isLocationPermissionDenied == rhs.isLocationPermissionDenied
        }
    }

    enum Action: Equatable {
        case locationUpdated(CLLocation)
        case locationPermissionDenied
        case locationPermissionGranted
        case requestLocationPermission
        case getCurrentLocationButtonTapped
        case alert(PresentationAction<Alert>)
        public enum Alert: Equatable {
            // TODO: アラートのボタンにアクションを追加したい場合はここにActionを追加
            // 設定アプリに遷移させる
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .locationUpdated(location):
                state.location = location
                return .none
            case .locationPermissionDenied:
                state.isLocationPermissionDenied = true
                return .none
            case .locationPermissionGranted:
                state.isLocationPermissionDenied = false
                return .none
            case .requestLocationPermission:
                LocationManager.shared.requestLocation()
                return .none
            case .getCurrentLocationButtonTapped:
                // 位置情報許可した場合→現在ボタン押下でユーザの位置情報を表示
                // 位置情報拒否した場合→現在ボタン押下でユーザのアラートを表示
                if state.isLocationPermissionDenied {
                    state.alert = .init(
                        title: .init("位置情報がオフになっているため、現在位置を表示できません。"),
                        buttons: [.cancel(.init("OK"))]
                    )
                }
                return .none
            case .alert:
                state.alert = nil
                return .none
            }
        }
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}
