//
//  FavoriteFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/17.
//

import ComposableArchitecture
import FirebaseFirestore

@Reducer
struct FavoriteFeature {
    @ObservableState
    struct State: Equatable {
        var favoritePilgrimageRows = IdentifiedArrayOf<PilgrimageRowFeature.State>()
        var isLoading = false
        var favorited = false
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear
        case fetchFavorites
        case pilgrimageResponse(Result<[PilgrimageInformation], APIError>)
        case setLoading(Bool)
        case setFavorited(Bool)
        case favoritePilgrimageRows(IdentifiedActionOf<PilgrimageRowFeature>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchFavorites)
            case .fetchFavorites:
                return .run { send in
                    await send(.setLoading(true))

                    do {
                        try await networkMonitor.monitorNetwork()

                        let uuid = await UIDevice.current.identifierForVendor!.uuidString
                        let querySnapshot = try await Firestore.firestore()
                            .collection("favorite-list")
                            .document(uuid)
                            .collection("list")
                            .getDocuments()
                        var favoritePilgrimages: [PilgrimageInformation] = []

                        for document in querySnapshot.documents {
                            let pilgrimage = try document.data(as: PilgrimageInformation.self)
                            favoritePilgrimages.append(pilgrimage)
                        }
                        await send(.pilgrimageResponse(.success(favoritePilgrimages)))
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.fetchFavoritePilgrimagesError)))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }

                    await send(.setLoading(false))
                }
            case let .favoritePilgrimageRows(.element(id, .delegate(.favoriteButtonTapped(pilgrimage)))):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                // ドキュメントを取得し、既にデータがある場合は削除し、ない場合はお気に入りに追加する
                return .run { send in
                    await send(.favoritePilgrimageRows(.element(id: id, action: .setLoading(true))))

                    do {
                        try await networkMonitor.monitorNetwork()

                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            // 既にデータがある場合はお気に入りから削除
                            try await documentReference.delete()
                            await send(.favoritePilgrimageRows(.element(id: id, action: .setFavorited(false))))
                        } else {
                            // ない場合はお気に入りに追加
                            let data: [String: Any?] = [
                                "code": pilgrimage.code,
                                "name": pilgrimage.name,
                                "description": pilgrimage.description,
                                "latitude": pilgrimage.latitude,
                                "longitude": pilgrimage.longitude,
                                "address": pilgrimage.address,
                                "image_url": pilgrimage.imageURL?.absoluteString,
                                "copyright": pilgrimage.copyright,
                                "search_candidate_list": pilgrimage.searchCandidateList
                            ]
                            try await documentReference.setData(data as [String : Any])
                            await send(.favoritePilgrimageRows(.element(id: id, action: .setFavorited(true))))
                        }
                        await send(.fetchFavorites)
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.favoritePilgrimageRows(.element(id: id, action: .pilgrimageResponse(.failure(.updateFavoritePilgrimagesError)))))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.favoritePilgrimageRows(.element(id: id, action: .pilgrimageResponse(.failure(.networkError)))))
                    }

                    await send(.favoritePilgrimageRows(.element(id: id, action: .setLoading(false))))
                }
            case let .pilgrimageResponse(.success(pilgrimages)):
                state.favoritePilgrimageRows = .init(response: pilgrimages)
                return .none
            case let .pilgrimageResponse(.failure(error)):
                switch error {
                case .networkError:
                    state.destination = .alert(.networkError)
                case .fetchFavoritePilgrimagesError:
                    state.destination = .alert(.fetchFavoritePilgrimagesError)
                case .updateFavoritePilgrimagesError:
                    state.destination = .alert(.updateFavoritePilgrimagesError)
                default: return .none
                }
                return .none
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            case let .setFavorited(favorited):
                state.favorited = favorited
                return .none
            case .favoritePilgrimageRows:
                return .none
            case .destination:
                return .none
            }
        }
        .forEach(\.favoritePilgrimageRows, action: \.favoritePilgrimageRows) {
            PilgrimageRowFeature()
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState where Action == FavoriteFeature.Destination.Alert {
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

extension FavoriteFeature {
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Alert>)

        enum Alert: Equatable {}
    }
}
