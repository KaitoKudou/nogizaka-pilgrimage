//
//  PilgrimageRepository.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros

@DependencyClient
struct PilgrimageRepository {
    var fetchAllPilgrimages: () async throws -> [PilgrimageInformation]
}
