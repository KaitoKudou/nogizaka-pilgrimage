//
//  LocationManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/22.
//

import AppLogger
import CoreLocation
import Observation

@Observable
final class LocationManager {
    /// ユーザーの現在地の位置座標
    private(set) var userLocation: CLLocationCoordinate2D?
    /// 位置情報の利用許可状態
    private(set) var isLocationPermissionDenied: Bool = true
    /// awaitLocation のタイムアウトが発火したかどうか
    private var isAwaitTimedOut = false
    private let delegate: Delegate
    private let clLocationManager = CLLocationManager()

    init() {
        delegate = Delegate()
        delegate.owner = self
    }

    /// 許可済みの場合のみ位置情報取得を開始する（許可ダイアログは表示しない）
    func requestLocationIfAuthorized() {
        let status = clLocationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            if status == .restricted || status == .denied {
                isLocationPermissionDenied = true
            }
            return
        }
        configureCLLocationManager()
        isLocationPermissionDenied = false
        clLocationManager.startUpdatingLocation()
    }

    /// userLocation に値が入るまで待機する。許可済みでなければ即座に返す。
    /// タイムアウト時は userLocation が nil のまま返る。
    @MainActor
    func awaitLocation(timeout: Duration = .seconds(5)) async {
        guard !isLocationPermissionDenied, userLocation == nil else { return }

        isAwaitTimedOut = false
        let deadline = ContinuousClock.now.advanced(by: timeout)

        let timeoutTask = Task { @MainActor in
            try? await Task.sleep(for: timeout)
            isAwaitTimedOut = true
        }

        while userLocation == nil && ContinuousClock.now < deadline {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                withObservationTracking {
                    _ = self.userLocation
                    _ = self.isAwaitTimedOut
                } onChange: {
                    continuation.resume()
                }
            }
        }

        timeoutTask.cancel()
    }

    func requestLocation() {
        configureCLLocationManager()

        if clLocationManager.authorizationStatus == .notDetermined {
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            clLocationManager.requestWhenInUseAuthorization()
        } else {
            switch clLocationManager.authorizationStatus {
            case .restricted, .denied:
                isLocationPermissionDenied = true
            case .authorizedWhenInUse:
                isLocationPermissionDenied = false
            default: break
            }
            clLocationManager.startUpdatingLocation()
        }
    }
}

private extension LocationManager {
    func configureCLLocationManager() {
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.distanceFilter = 5
        clLocationManager.delegate = delegate
    }

    final class Delegate: NSObject, CLLocationManagerDelegate {
        weak var owner: LocationManager?

        /// 許可状態のステータスが変更された際に呼ばれる
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .notDetermined:
                // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // .restricted: 位置情報を利用する権限がない
                // .denied: ユーザが明示的に位置情報の利用を拒否
                owner?.isLocationPermissionDenied = true
            case .authorizedWhenInUse:
                // アプリを使用している間のみ位置情報の利用を許可
                // 位置情報利用が許可がされたらStateに通知
                manager.startUpdatingLocation()
                owner?.isLocationPermissionDenied = false
            case .authorizedAlways:
                // 位置情報の利用を常に許可
                break
            @unknown default:
                break
            }
        }

        /// 位置情報取得成功時に呼ばれる
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {
                manager.stopUpdatingLocation()
                return
            }
            owner?.userLocation = location.coordinate
        }

        /// 位置情報取得失敗時に呼ばれる
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            #log(.error, "didFailWithError: \(error.localizedDescription)")
        }
    }
}
