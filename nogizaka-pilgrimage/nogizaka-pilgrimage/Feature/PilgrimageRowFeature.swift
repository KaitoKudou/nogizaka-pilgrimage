//
//  PilgrimageRowFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/10.
//

import ComposableArchitecture
import FirebaseFirestore

@Reducer
struct PilgrimageRowFeature {
    @ObservableState
    struct State: Identifiable, Equatable {
        var id: Int { pilgrimage.id }
        let pilgrimage: PilgrimageInformation
        var isLoading = false
        var favorited = false
        @Presents var destination: Destination.State?

        static func make(from item: PilgrimageInformation) -> Self {
            .init(pilgrimage: .init(from: item))
        }
    }

    enum Action {
        case onAppear(PilgrimageInformation)
        case updateFavorite(PilgrimageInformation)
        case delegate(Delegate)
        case setLoading(Bool)
        case setFavorited(Bool)
        case pilgrimageResponse(Result<[PilgrimageInformation], APIError>)
        case destination(PresentationAction<Destination.Action>)

        public enum Delegate {
            case favoriteButtonTapped(PilgrimageInformation)
        }
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore()
                    .collection("favorite-list")
                    .document(uuid)
                    .collection("list")

                return .run { send in
                    do {
                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            await send(.setFavorited(true))
                        } else {
                            await send(.setFavorited(false))
                        }
                    }
                }
            case let .updateFavorite(pilgrimage):
                return .send(.delegate(.favoriteButtonTapped(pilgrimage)))
            case .delegate:
                return .none
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            case let .setFavorited(favorited):
                state.favorited = favorited
                return .none
            case .pilgrimageResponse(.success(_)):
                return .none
            case let .pilgrimageResponse(.failure(error)):
                switch error {
                case .fetchFavoritePilgrimagesError:
                    state.destination = .alert(.fetchFavoritePilgrimagesError)
                case .updateFavoritePilgrimagesError:
                    state.destination = .alert(.updateFavoritePilgrimagesError)
                case .networkError:
                    state.destination = .alert(.networkError)
                default: return .none
                }
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == PilgrimageRowFeature.Destination.Alert {
    static let fetchFavoritePilgrimagesError = Self {
        TextState(APIError.fetchFavoritePilgrimagesError.localizedDescription)
    }

    static let updateFavoritePilgrimagesError = Self {
        TextState(APIError.updateFavoritePilgrimagesError.localizedDescription)
    }

    static let networkError = Self {
        TextState(APIError.networkError.localizedDescription)
    }
}

extension PilgrimageRowFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable {}
    }
}

extension IdentifiedArrayOf
where Element == PilgrimageRowFeature.State, ID == Int {
    init(response: [PilgrimageInformation]) {
        self = IdentifiedArrayOf(uniqueElements: response.map { .make(from: $0) })
    }
}
