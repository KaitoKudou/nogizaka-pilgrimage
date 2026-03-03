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
    var fetchCheckedInPilgrimages: () async throws -> [PilgrimageInformation]
    var isCheckedIn: (_ name: String) async throws -> Bool
    var addCheckIn: (_ pilgrimage: PilgrimageInformation) async throws -> Void
}
