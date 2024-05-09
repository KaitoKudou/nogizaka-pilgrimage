//
//  InitialFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/28.
//

import ComposableArchitecture
import FirebaseFirestore

@Reducer
struct InitialFeature {
    @ObservableState
    struct State: Equatable {
        var shouldUpdate = false
        var isLoading = true
        var appUpdateInfo: AppUpdateInformation?
        var pilgrimages: [PilgrimageInformation] = []
        var hasError = false
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear
        case fetchAllPilgrimage
        case appUpdateInfoResponse(Result<AppUpdateInformation, APIError>)
        case pilgrimageResponse(Result<[PilgrimageInformation], APIError>)
        case startLoading
        case stopLoading
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.applicationClient) var applicationClient
    @Dependency(\.buildClient) var buildClient
    @Dependency(\.networkMonitor) var networkMonitor

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        try await networkMonitor.monitorNetwork()

                        let appUpdateInfo = try await Firestore.firestore()
                            .collection("configure")
                            .document("update")
                            .getDocument()
                            .data(as: AppUpdateInformation.self)
                        await send(.appUpdateInfoResponse(.success(appUpdateInfo)))

                    } catch {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }

                    await send(.fetchAllPilgrimage)
                }
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
            case let .appUpdateInfoResponse(.success(appUpdateInfo)):
                state.hasError = false

                if appUpdateInfo.targetVersion.compare(buildClient.appVersion()) == .orderedDescending {
                    // アップデート促進アラートを表示
                    state.shouldUpdate = true
                    state.appUpdateInfo = appUpdateInfo
                    state.destination = .alert(.updatePromotionAlert(appUpdateInfo: appUpdateInfo))
                }
                return .none
            case let .appUpdateInfoResponse(.failure(error)):
                state.hasError = true
                return .run { send in
                    await send(.pilgrimageResponse(.failure(error)))
                }
            case let .pilgrimageResponse(.success(pilgrimages)):
                state.pilgrimages = pilgrimages
                state.hasError = false
                return .none
            case let .pilgrimageResponse(.failure(error)):
                state.hasError = true
                switch error {
                case .fetchPilgrimagesError:
                    state.destination = .alert(.fetchPilgrimagesFailureAlert())
                case .networkError:
                    state.destination = .alert(.networkErrorAlert())
                default: return .none
                }
                return .none
            case .startLoading:
                state.isLoading = true
                return .none
            case .stopLoading:
                state.isLoading = false
                return .none
            case .destination(.presented(.alert(.update))):
                return .run { send in
                    _ = await self.applicationClient.open(
                        URL(string: "https://apps.apple.com/jp/app/id6501994754")!, [:]
                    )
                    await send(.onAppear)
                }
            case .destination(.presented(.alert(.retryFetchPilgrimages))):
                return .run { send in
                    await send(.fetchAllPilgrimage)
                }
            case .destination:
                state.shouldUpdate = false
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == InitialFeature.Destination.Alert {
    static func fetchPilgrimagesFailureAlert() -> Self {
        Self {
            TextState(APIError.fetchPilgrimagesError.localizedDescription)
        } actions: {
            ButtonState(action: .retryFetchPilgrimages) {
                TextState(R.string.localizable.alert_ok())
            }
        }
    }

    static func networkErrorAlert() -> Self {
        Self {
            TextState(APIError.networkError.localizedDescription)
        } actions: {
            ButtonState(action: .retryFetchPilgrimages) {
                TextState(R.string.localizable.alert_ok())
            }
        }
    }

    static func updatePromotionAlert(appUpdateInfo: AppUpdateInformation) -> Self {
        Self {
            TextState(appUpdateInfo.title)
        } actions: {
            if !appUpdateInfo.isForce {
                ButtonState(action: .later) {
                    TextState(R.string.localizable.alert_optional_update())
                }
            }

            ButtonState(action: .update) {
                TextState(R.string.localizable.alert_force_update())
            }
        } message: {
            TextState(appUpdateInfo.message)
        }
    }
}

extension InitialFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable {
            case later
            case update
            case retryFetchPilgrimages
        }
    }
}
