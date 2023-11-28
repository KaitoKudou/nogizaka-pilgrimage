//
//  LocationManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/22.
//

import ComposableArchitecture
import CoreLocation

final class LocationManager: NSObject {
    private var locationManager = CLLocationManager()
    private var viewStore: ViewStore<UserLocationFeature.State, UserLocationFeature.Action>?
    static let shared = LocationManager()

    private override init() {
        super.init()
        configureLocationManager()
    }

    private func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
        locationManager.delegate = self
    }

    func setViewStore(_ viewStore: ViewStore<UserLocationFeature.State, UserLocationFeature.Action>) {
        self.viewStore = viewStore
    }

    func requestLocation() {
        // initで設定を書くと，アプリ起動時に許可ダイアログが出てしまうためここ設定を行う
        if locationManager.authorizationStatus == .notDetermined {
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            locationManager.requestWhenInUseAuthorization()
        } else {
            // ユーザーの現在地の配信を１回だけ要求する
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// 許可状態のステータスが変更された際に呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // .restricted: 位置情報を利用する権限がない
            // .denied: ユーザが明示的に位置情報の利用を拒否
            // 位置情報利用が拒否がされたらStateに通知
            viewStore?.send(.locationPermissionDenied)
        case .authorizedWhenInUse:
            // アプリを使用している間のみ位置情報の利用を許可
            // 位置情報利用が許可がされたらStateに通知
            locationManager.startUpdatingLocation()
            viewStore?.send(.locationPermissionGranted)
        case .authorizedAlways:
            // 位置情報の利用を常に許可
            break
        @unknown default:
            break
        }
    }

    /// 位置情報取得成功時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Locationが更新されたら、Stateに通知
        if let location = locations.last {
            viewStore?.send(.locationUpdated(location))
        }
    }

    /// 位置情報取得失敗時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError error=\(error.localizedDescription)")
    }
}
