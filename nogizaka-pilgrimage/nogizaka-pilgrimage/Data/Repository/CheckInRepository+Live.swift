//
//  CheckInRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies

extension CheckInRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(CheckInRemoteDataStore.self) var remoteDataStore
        @Dependency(CheckInLocalDataStore.self) var localDataStore
        @Dependency(PilgrimageLocalDataStore.self) var pilgrimageLocalDataStore

        return .init(
            fetchCheckedInPilgrimages: {
                do {
                    if let codes = try await localDataStore.getAll(),
                       let objects = try await pilgrimageLocalDataStore.getAll() {
                        let codeSet = Set(codes)
                        return objects.filter { codeSet.contains($0.code) }.map { $0.toDomain() }
                    }
                    let dtos = try await remoteDataStore.fetchAll()
                    let codes = dtos.map(\.code)
                    try await localDataStore.setAll(codes)
                    if let objects = try await pilgrimageLocalDataStore.getAll() {
                        let codeSet = Set(codes)
                        return objects.filter { codeSet.contains($0.code) }.map { $0.toDomain() }
                    }
                    return []
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            },
            isCheckedIn: { code in
                do {
                    return try await localDataStore.contains(code)
                } catch {
                    throw APIError.unknownError
                }
            },
            addCheckIn: { pilgrimage in
                do {
                    try await remoteDataStore.add(PilgrimageDTO(from: pilgrimage))
                    try await localDataStore.add(pilgrimage.code)
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            }
        )
    }()
}
