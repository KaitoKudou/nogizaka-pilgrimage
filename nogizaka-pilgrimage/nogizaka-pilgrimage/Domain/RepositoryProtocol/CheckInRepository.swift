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
    var fetchCheckedInPilgrimages: () async throws -> [PilgrimageEntity]
    var isCheckedIn: (_ code: String) async throws -> Bool
    var addCheckIn: (_ pilgrimage: PilgrimageEntity) async throws -> Void
}
