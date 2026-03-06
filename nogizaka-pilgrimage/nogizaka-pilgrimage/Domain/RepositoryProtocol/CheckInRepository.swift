//
//  CheckInRepository.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct CheckInRepository {
    var fetchCheckedInPilgrimages: @Sendable () async throws -> [PilgrimageEntity]
    var isCheckedIn: @Sendable (_ code: String) async throws -> Bool
    var addCheckIn: @Sendable (_ pilgrimage: PilgrimageEntity) async throws -> Void
}
