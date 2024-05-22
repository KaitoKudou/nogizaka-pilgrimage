//
//  PilgrimageDetailFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/18.
//

import ComposableArchitecture
import CoreLocation
import FirebaseFirestore
import UIKit

@Reducer
struct PilgrimageDetailFeature {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var favorited = false
        var hasCheckedIn = false
        @Presents var destination: Destination.State?
    }

    enum Action {
        case onAppear(PilgrimageInformation)
        case verifyFavorited(PilgrimageInformation)
        case verifyCheckedIn(PilgrimageInformation)
        case favoriteButtonTapped(PilgrimageInformation)
        case checkInButtonTapped(pilgrimage: PilgrimageInformation, userCoordinate: CLLocationCoordinate2D)
        case checkIn(PilgrimageInformation)
        case pilgrimageResponse(Result<[PilgrimageInformation]?, APIError>)
        case notNearbyError
        case setLoading(Bool)
        case setFavorited(Bool)
        case updateCheckedInStatus(Bool)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(pilgrimage):
                return .run { send in
                    await send(.verifyFavorited(pilgrimage))
                    await send(.verifyCheckedIn(pilgrimage))
                }
            case let .verifyFavorited(pilgrimage):
                return verifyFavorited(by: pilgrimage)
            case let .verifyCheckedIn(pilgrimage):
                return verifyCheckedIn(by: pilgrimage)
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
            case let .checkInButtonTapped(pilgrimage, userCoordinate):
                return .run { send in
                    // 現在地と聖地までの距離を測る(判定をBoolで保持)
                    if isNearbyPilgrimage(userCoordinate: userCoordinate, pilgrimageCoordinate: pilgrimage.coordinate) {
                        // 現在地と聖地までの距離が100m以内だったらチェックイン処理を実行
                        await send(.checkIn(pilgrimage))
                    } else {
                        // 100m以内じゃないなら、アラートを出す
                        await send(.notNearbyError)
                    }
                }
            case let .checkIn(pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("checked-in-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                return .run { send in
                    await send(.setLoading(true))
                    do {
                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            await send(.updateCheckedInStatus(false))
                        } else {
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
                            await send(.pilgrimageResponse(.success(nil)))
                            await send(.updateCheckedInStatus(true))
                        }
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.updateCheckedInError)))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.pilgrimageResponse(.failure(.networkError)))
                    }
                    await send(.setLoading(false))
                }
            case .notNearbyError:
                state.destination = .alert(.notNearbyError)
                return .none
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            case let .setFavorited(favorited):
                state.favorited = favorited
                return .none
            case let .updateCheckedInStatus(hasCheckedIn):
                state.hasCheckedIn = hasCheckedIn
                return .none
            case .destination:
                return .none
            case .pilgrimageResponse(.success(_)):
                return .none
            case let .pilgrimageResponse(.failure(error)):
                switch error {
                case .updateFavoritePilgrimagesError:
                    state.destination = .alert(.updateFavoritePilgrimagesError)
                case .updateCheckedInError:
                    state.destination = .alert(.updateCheckedInError)
                case .networkError:
                    state.destination = .alert(.networkError)
                default: return .none
                }
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
    /// チェックインしているか確認
    func verifyCheckedIn(by pilgrimage: PilgrimageInformation) -> Effect<Action> {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore()
            .collection("checked-in-list")
            .document(uuid)
            .collection("list")

        return .run { send in
            do {
                if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                    await send(.updateCheckedInStatus(true))
                } else {
                    await send(.updateCheckedInStatus(false))
                }
            }
        }
    }

    /// 現在地と聖地までの距離が200m以内かどうか判定
    func isNearbyPilgrimage(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D) -> Bool {
        let distanceThreshold = 200.0
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)

        if userLocation.distance(from: pilgrimageLocation) < distanceThreshold {
            return true
        } else {
            return false
        }
    }
}

extension AlertState where Action == PilgrimageDetailFeature.Destination.Alert {
    static let notNearbyError = Self {
        TextState(R.string.localizable.alert_not_nearby())
    }

    static let updateCheckedInError = Self {
        TextState(APIError.updateCheckedInError.localizedDescription)
    }

    static let updateFavoritePilgrimagesError = Self {
        TextState(APIError.updateFavoritePilgrimagesError.localizedDescription)
    }

    static let networkError = Self {
        TextState(APIError.networkError.localizedDescription)
    }
}

extension PilgrimageDetailFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable {}
    }
}

