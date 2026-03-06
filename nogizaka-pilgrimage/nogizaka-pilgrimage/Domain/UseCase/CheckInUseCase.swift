//
//  CheckInUseCase.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import CoreLocation
import Dependencies
import DependenciesMacros

@DependencyClient
struct CheckInUseCase {
    var execute: @Sendable (_ pilgrimage: PilgrimageEntity, _ userCoordinate: CLLocationCoordinate2D) async throws -> Bool
}

extension CheckInUseCase: DependencyKey {
    static let liveValue: Self = {
        @Dependency(CheckInRepository.self) var checkInRepository

        return .init(
            execute: { pilgrimage, userCoordinate in
                let distanceThreshold = 200.0
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                let pilgrimageLocation = CLLocation(
                    latitude: pilgrimage.coordinate.latitude,
                    longitude: pilgrimage.coordinate.longitude
                )
                guard userLocation.distance(from: pilgrimageLocation) < distanceThreshold else {
                    throw CheckInError.notNearby
                }

                guard try await !checkInRepository.isCheckedIn(pilgrimage.code) else {
                    return false
                }

                try await checkInRepository.addCheckIn(pilgrimage)
                return true
            }
        )
    }()
}

enum CheckInError: Error {
    case notNearby
}
