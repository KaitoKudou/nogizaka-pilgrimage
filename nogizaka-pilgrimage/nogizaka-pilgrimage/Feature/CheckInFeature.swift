//
//  CheckInFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import FirebaseFirestore
import ComposableArchitecture
import CoreLocation

@Reducer
struct CheckInFeature {
    @ObservableState
    struct State: Equatable {
        var checkedInPilgrimages: [PilgrimageInformation] = []
        var isLoading: Bool = false
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear
        case setLoading(Bool)
        case pilgrimageResponse(Result<[PilgrimageInformation]?, APIError>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.setLoading(true))

                    do {
                        let uuid = await UIDevice.current.identifierForVendor!.uuidString
                        let querySnapshot = try await Firestore.firestore()
                            .collection("checked-in-list")
                            .document(uuid)
                            .collection("list")
                            .getDocuments()
                        var checkedInPilgrimages: [PilgrimageInformation] = []

                        for document in querySnapshot.documents {
                            let pilgrimage = try document.data(as: PilgrimageInformation.self)
                            checkedInPilgrimages.append(pilgrimage)
                        }
                        await send(.pilgrimageResponse(.success(checkedInPilgrimages)))
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.fetchCheckedInError)))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }

                    await send(.setLoading(false))
                }
            case let .pilgrimageResponse(.success(pilgrimages)):
                guard let pilgrimages = pilgrimages else { return .none }
                state.checkedInPilgrimages = pilgrimages
                return .none
            case let .pilgrimageResponse(.failure(error)):
                switch error {
                case .networkError:
                    state.destination = .alert(.networkError)
                case .fetchCheckedInError:
                    state.destination = .alert(.fetchCheckedInError)
                default: return .none
                }
                return .none
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == CheckInFeature.Destination.Alert {
    static let fetchCheckedInError = Self {
        TextState(APIError.fetchCheckedInError.localizedDescription)
    }

    static let networkError = Self {
        TextState(APIError.networkError.localizedDescription)
    }
}

extension CheckInFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable {}
    }
}
