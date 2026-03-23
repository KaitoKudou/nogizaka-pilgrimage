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
                    if let checkInObjects = try await localDataStore.getAll(),
                       let pilgrimageObjects = try await pilgrimageLocalDataStore.getAll() {
                        let codeSet = Set(checkInObjects.map(\.pilgrimageCode))
                        return pilgrimageObjects.filter { codeSet.contains($0.code) }.map { $0.toDomain() }
                    }
                    let dtos = try await remoteDataStore.fetchAll()
                    let entities = dtos.map {
                        CheckInEntity(
                            pilgrimageCode: $0.pilgrimageDTO.code,
                            checkedInAt: $0.checkedInAt,
                            memo: $0.memo
                        )
                    }
                    try await localDataStore.setAll(records: entities)
                    if let pilgrimageObjects = try await pilgrimageLocalDataStore.getAll() {
                        let codeSet = Set(entities.map(\.pilgrimageCode))
                        return pilgrimageObjects.filter { codeSet.contains($0.code) }.map { $0.toDomain() }
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
                    return try await localDataStore.contains(code: code)
                } catch {
                    throw APIError.unknownError
                }
            },
            addCheckIn: { pilgrimage, checkedInAt, memo in
                // TODO: バリデーションはビジネスルールのためDomain層に移動すべき。現在は@DependencyClientの構造上liveValueに配置している
                if let memo {
                    guard memo.count <= Constants.memoMaxLength else { throw CheckInError.memoTooLong }
                }
                do {
                    let dto = CheckInDTO(
                        pilgrimageDTO: PilgrimageDTO(from: pilgrimage),
                        checkedInAt: checkedInAt,
                        memo: memo
                    )
                    try await remoteDataStore.add(dto: dto)
                    try await localDataStore.add(code: pilgrimage.code, checkedInAt: checkedInAt, memo: memo)
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            },
            updateCheckedInAt: { code, newDate in
                do {
                    try await remoteDataStore.updateCheckedInAt(code: code, newDate: newDate)
                    try await localDataStore.updateCheckedInAt(code: code, newDate: newDate)
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            },
            updateMemo: { code, memo in
                // TODO: バリデーションはビジネスルールのためDomain層に移動すべき。現在は@DependencyClientの構造上liveValueに配置している
                if let memo {
                    guard memo.count <= Constants.memoMaxLength else { throw CheckInError.memoTooLong }
                }
                do {
                    try await remoteDataStore.updateMemo(code: code, memo: memo)
                    try await localDataStore.updateMemo(code: code, memo: memo)
                } catch let error as APIError {
                    throw error
                } catch {
                    throw APIError.unknownError
                }
            }
        )
    }()
}
