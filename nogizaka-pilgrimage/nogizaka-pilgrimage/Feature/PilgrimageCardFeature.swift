//
//  PilgrimageCardFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/18.
//

import ComposableArchitecture
import FirebaseFirestore
import UIKit

@Reducer
struct PilgrimageCardFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var favorited = false
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear(PilgrimageInformation)
        case favoriteButtonTapped(PilgrimageInformation)
        case routeButtonTapped(latitude: String, longitude: String)
        case setLoading(Bool)
        case setFavorited(Bool)
        case pilgrimageResponse(Result<[PilgrimageInformation]?, APIError>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor
    @Dependency(\.routeActionClient) var routeActionClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(pilgrimage):
                return verifyFavorited(by: pilgrimage)
            case let .favoriteButtonTapped(pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                // ドキュメントを取得し、既にデータがある場合は削除し、ない場合はお気に入りに追加する
                return .run { send in
                    await send(.setLoading(true))
                    do {
                        try await networkMonitor.monitorNetwork()

                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            // 既にデータがある場合はお気に入りから削除
                            try await documentReference.delete()
                            await send(.setFavorited(false))
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
                            await send(.setFavorited(true))
                        }
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.updateFavoritePilgrimagesError)))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }
                    await send(.setLoading(false))
                }
            case let .routeButtonTapped(latitude, longitude):
                state.destination = .confirmationDialog(
                    .startupMapAppDialog(latitude: latitude, longitude: longitude)
                )
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
                case .updateFavoritePilgrimagesError:
                    state.destination = .alert(.updateFavoritePilgrimagesError)
                case .networkError:
                    state.destination = .alert(.networkError)
                default: return .none
                }
                return .none
            case let .destination(
                .presented(
                    .confirmationDialog(
                        .appleMapButtonTapped(latitude, longitude)
                    )
                )
            ):
                return .run { _ in
                    await routeActionClient.viewOnMap(latitude, longitude)
                }
            case let .destination(
                .presented(
                    .confirmationDialog(
                        .googleMapsButtonTapped(latitude, longitude)
                    )
                )
            ):
                return .run { _ in
                    await routeActionClient.viewOnGoogleMaps(latitude, longitude)
                }
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    /// お気に入りしているか確認
    func verifyFavorited(by pilgrimage: PilgrimageInformation) -> Effect<Action> {
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
    }
}

extension AlertState where Action == PilgrimageCardFeature.Destination.Alert {
    static let updateFavoritePilgrimagesError = Self {
        TextState(APIError.updateFavoritePilgrimagesError.localizedDescription)
    }

    static let networkError = Self {
        TextState(APIError.networkError.localizedDescription)
    }
}

extension ConfirmationDialogState where Action == PilgrimageCardFeature.Destination.ConfirmationDialog {
    static func startupMapAppDialog(latitude: String, longitude: String) -> Self {
        Self {
            TextState("")
        } actions: {
            ButtonState(role: .cancel) {
                TextState(R.string.localizable.confirmation_dialog_cancel())
            }
            ButtonState(action: .appleMapButtonTapped(latitude: latitude, longitude: longitude)) {
                TextState(R.string.localizable.confirmation_dialog_apple_map())
            }
            ButtonState(action: .googleMapsButtonTapped(latitude: latitude, longitude: longitude)) {
                TextState(R.string.localizable.confirmation_dialog_google_maps())
            }
        }
    }
}

extension PilgrimageCardFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        case confirmationDialog(ConfirmationDialogState<ConfirmationDialog>)

        public enum Alert: Equatable {}
        public enum ConfirmationDialog: Equatable {
            case appleMapButtonTapped(latitude: String, longitude: String)
            case googleMapsButtonTapped(latitude: String, longitude: String)
        }
    }
}

