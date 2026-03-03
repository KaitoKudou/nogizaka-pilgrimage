//
//  CheckInRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import FirebaseFirestore

extension CheckInRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(CheckInRemoteDataStore.self) var remoteDataStore
        @Dependency(CheckInLocalDataStore.self) var localDataStore

        return .init(
            fetchCheckedInPilgrimages: {
                do {
                    let result = try await remoteDataStore.fetchAll()
                    await localDataStore.setAll(result)
                    return result
                } catch {
                    throw mapError(error, to: .fetchCheckedInError)
                }
            },
            isCheckedIn: { name in
                if let cached = await localDataStore.getAll() {
                    return cached.contains { $0.name == name }
                }
                do {
                    let result = try await remoteDataStore.fetchAll()
                    await localDataStore.setAll(result)
                    return result.contains { $0.name == name }
                } catch {
                    throw mapError(error, to: .fetchCheckedInError)
                }
            },
            addCheckIn: { pilgrimage in
                do {
                    try await remoteDataStore.add(pilgrimage)
                    await localDataStore.add(pilgrimage)
                } catch {
                    throw mapError(error, to: .updateCheckedInError)
                }
            }
        )
    }()

    private static func mapError(_ error: Error, to apiError: APIError) -> APIError {
        if (error as NSError).domain == FirestoreErrorDomain {
            return apiError
        }
        return .unknownError
    }
}
