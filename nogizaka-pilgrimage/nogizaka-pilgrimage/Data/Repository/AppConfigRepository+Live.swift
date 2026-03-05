//
//  AppConfigRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies

extension AppConfigRepository: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AppConfigRemoteDataStore.self) var remoteDataStore

        return .init(
            fetchUpdateInfo: {
                do {
                    return try await remoteDataStore.fetchUpdateInfo()
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            }
        )
    }()
}
