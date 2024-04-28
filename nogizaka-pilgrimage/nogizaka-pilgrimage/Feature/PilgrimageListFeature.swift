//
//  PilgrimageListFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/10.
//

import ComposableArchitecture
import FirebaseFirestore
import SwiftUI

@Reducer
struct PilgrimageListFeature {
    @ObservableState
    struct State: Equatable {
        var scrollToIndex = 0
        var isLoading = false
        var searchText = ""
        var pilgrimageRows = IdentifiedArrayOf<PilgrimageRowFeature.State>()
        var pilgrimageSearchResults = IdentifiedArrayOf<PilgrimageRowFeature.State>()
        @Presents var destination: Destination.State?
        var path = StackState<PilgrimageDetailFeature.State>()
    }

    enum Action {
        case onAppear([PilgrimageInformation])
        case updateScrollToIndex(scrollToIndex: Int)
        case searchPilgrimages(String)
        case updateSearchText(String)
        case search(String)
        case setLoading(Bool)
        case resetSearchResults
        case pilgrimageRows(IdentifiedActionOf<PilgrimageRowFeature>)
        case path(StackAction<PilgrimageDetailFeature.State, PilgrimageDetailFeature.Action>)
    }

    @Dependency(\.networkMonitor) var networkMonitor

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .onAppear(pilgrimageRows):
                state.pilgrimageRows = .init(response: pilgrimageRows)
                return .none
            case let .updateScrollToIndex(scrollToIndex):
                state.scrollToIndex = scrollToIndex
                return .none
            case .resetSearchResults:
                state.pilgrimageSearchResults = []
                return .none
            case let .searchPilgrimages(searchText):
                return .run { send in
                    await send(.setLoading(true))
                    await send(.updateSearchText(searchText))
                    await send(.resetSearchResults)
                    await send(.search(searchText))
                    await send(.setLoading(false))
                }
            case let .updateSearchText(searchText):
                if state.searchText != searchText {
                    state.scrollToIndex = 0
                }

                state.searchText = searchText
                return .none
            case let .search(searchText):
                if searchText.isEmpty {
                    state.pilgrimageSearchResults = state.pilgrimageRows
                } else {
                    state.pilgrimageSearchResults = state.pilgrimageRows.filter {
                        let normalizedSearchText = searchText.normalizedString
                        let normalizedSearchCandidates = $0.pilgrimage.searchCandidateList.map { $0.normalizedString }

                        // 部分一致を確認する
                        let matchingCandidates = normalizedSearchCandidates.filter {
                            $0.range(of: normalizedSearchText, options: .caseInsensitive) != nil
                        }

                        return !matchingCandidates.isEmpty
                    }
                }

                return .none
            case let .setLoading(isLoading):
                state.isLoading = isLoading
                return .none
            case let .pilgrimageRows(.element(id, .delegate(.favoriteButtonTapped(pilgrimage)))):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                // ドキュメントを取得し、既にデータがある場合は削除し、ない場合はお気に入りに追加する
                return .run { send in
                    await send(.pilgrimageRows(.element(id: id, action: .setLoading(true))))

                    do {
                        try await networkMonitor.monitorNetwork()

                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            // 既にデータがある場合はお気に入りから削除
                            try await documentReference.delete()
                            await send(.pilgrimageRows(.element(id: id, action: .setFavorited(false))))
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
                            await send(.pilgrimageRows(.element(id: id, action: .setFavorited(true))))
                        }
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageRows(.element(id: id, action: .pilgrimageResponse(.failure(.updateFavoritePilgrimagesError)))))
                    } catch let error as APIError where error == APIError.networkError {
                        await send(.pilgrimageRows(.element(id: id, action: .pilgrimageResponse(.failure(.networkError)))))
                    }

                    await send(.pilgrimageRows(.element(id: id, action: .setLoading(false))))
                }
            case .pilgrimageRows:
                return .none
            case .path(.element(id: _, action: .init())):
                print("詳細画面に遷移するよ")
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.pilgrimageSearchResults, action: \.pilgrimageRows) {
            PilgrimageRowFeature()
        }
    }
}

extension PilgrimageListFeature {
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Alert>)

        enum Alert: Equatable {}
    }
}

extension String {
    var normalizedString: String {
        return folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
