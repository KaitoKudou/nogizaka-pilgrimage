//
//  InitialFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/28.
//

import ComposableArchitecture
import FirebaseFirestore

struct InitialFeature: Reducer {
    struct State: Equatable {
        var isLoading = true
        var pilgrimages: [PilgrimageInformation] = []
        var hasError = false
        @PresentationState var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.fetchAllPilgrimage, .fetchAllPilgrimage):
                return true
            case let (.pilgrimageResponse(lhsResult), .pilgrimageResponse(rhsResult)):
                switch (lhsResult, rhsResult) {
                case (.success(let lhsValue), .success(let rhsValue)):
                    return lhsValue == rhsValue
                case (.failure(let lhsError), .failure(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                default:
                    return false
                }
            case (.startLoading, .startLoading):
                return true
            case (.stopLoading, .stopLoading):
                return true
            case (.fetchPilgrimagesFailureAlert(_), .fetchPilgrimagesFailureAlert(_)):
                return true
            case (.alertDismissed, .alertDismissed):
                return true
            default:
                return false
            }
        }

        case fetchAllPilgrimage
        case pilgrimageResponse(Result<[PilgrimageInformation], APIError>)
        case startLoading
        case stopLoading
        case fetchPilgrimagesFailureAlert(message: String)
        case alertDismissed(PresentationAction<Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchAllPilgrimage:
                return .run { send in
                    await send(.startLoading)

                    do {
                        try await networkMonitor.monitorNetwork()

                        let querySnapshot = try await Firestore.firestore().collection("pilgrimage-list").getDocuments()
                        var pilgrimages: [PilgrimageInformation] = []

                        for document in querySnapshot.documents {
                            let pilgrimage = try document.data(as: PilgrimageInformation.self)
                            pilgrimages.append(pilgrimage)
                        }
                        let sortedArray = pilgrimages.sorted { (first, second) -> Bool in
                            return first.code < second.code
                        }
                        await send(.pilgrimageResponse(.success(sortedArray)))
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.fetchPilgrimagesError)))
                    } catch {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }

                    await send(.stopLoading)
                }
            case let .pilgrimageResponse(.success(pilgrimages)):
                state.pilgrimages = pilgrimages
                state.hasError = false
                return .none
            case let .pilgrimageResponse(.failure(error)):
                state.hasError = true
                return .run { send in
                    await send(.fetchPilgrimagesFailureAlert(message: error.localizedDescription))
                }
            case .startLoading:
                state.isLoading = true
                return .none
            case .stopLoading:
                state.isLoading = false
                return .none
            case let .fetchPilgrimagesFailureAlert(errorMessage):
                state.alert = .init(
                    title: .init(errorMessage)
                )
                return .none
            case .alertDismissed:
                state.alert = nil
                return .run { send in
                    await send(.fetchAllPilgrimage)
                }
            }
        }
    }
}
