//
//  FavoriteFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/17.
//

import ComposableArchitecture
import FirebaseFirestore

struct FavoriteFeature: Reducer {
    struct State: Equatable {
        var favoritePilgrimages: [PilgrimageInformation] = []
        var isLoading = false
        @PresentationState var alert: AlertState<Action>?
    }

    enum Action: Equatable {
        case fetchFavorites
        case updateFavoriteList(PilgrimageInformation)
        case updateFavoriteCodes(PilgrimageInformation)
        case alertDismissed(PresentationAction<Action>)
        case pilgrimageResponse(TaskResult<[PilgrimageInformation]>)
        case startLoading
        case stopLoading
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchFavorites:
                return .run { send in
                    await send(.startLoading)

                    do {
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
                    } catch {
                        await send(.pilgrimageResponse(.failure(error)))
                    }

                    await send(.stopLoading)
                }
            case let .updateFavoriteList(pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                // ドキュメントを取得し、既にデータがある場合は削除し、ない場合はお気に入りに追加する
                return .run { send in
                    await send(.startLoading)
                    do {
                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            // 既にデータがある場合はお気に入りから削除
                            try await documentReference.delete()
                            await send(.updateFavoriteCodes(pilgrimage))
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
                            await send(.updateFavoriteCodes(pilgrimage))
                        }
                        await send(.fetchFavorites)
                    } catch  {
                        await send(.pilgrimageResponse(.failure(error)))
                    }
                    await send(.stopLoading)
                }
            case let .updateFavoriteCodes(pilgrimages):
                UserDefaultsManager.shared.updateList(code: pilgrimages.code, userDefaultsKey: .favorite)
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case let .pilgrimageResponse(.success(pilgrimages)):
                state.favoritePilgrimages = pilgrimages
                return .none
            case .pilgrimageResponse(.failure(_)):
                return .none
            case .startLoading:
                state.isLoading = true
                return .none
            case .stopLoading:
                state.isLoading = false
                return .none
            }
        }
    }
}
