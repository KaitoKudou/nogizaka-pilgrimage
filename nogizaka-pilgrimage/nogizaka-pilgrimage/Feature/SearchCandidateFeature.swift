//
//  SearchCandidateFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/30.
//

import ComposableArchitecture

struct SearchCandidateFeature: Reducer {
    struct State: Equatable {
        var allSearchCandidatePilgrimages: [PilgrimageInformation] = [] // 検索結果の配列(一覧)
        var searchText: String = ""
        var isLoading: Bool = false
    }

    enum Action: Equatable {
        case searchPilgrimages(String)
        case startLoading
        case stopLoading
        case resetPilgrimages
        case searchAllPilgrimages // 一覧から検索
        case searchPilgrimagesResponse([PilgrimageInformation])
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .resetPilgrimages:
                // 初回立ち上げ時 and 空文字での検索時に実行
                state.allSearchCandidatePilgrimages = dummyPilgrimageList
                return .none

            case let .searchPilgrimages(text):
                state.searchText = text

                return .run { send in
                    await send(.startLoading)
                    await send(.searchAllPilgrimages)
                }

            case .startLoading:
                state.isLoading = true
                return .none

            case .stopLoading:
                state.isLoading = false
                return .none

            case .searchAllPilgrimages:
                let filteredPilgrimages = searchPilgrimages(with: state.searchText, searchTarget: dummyPilgrimageList)
                return .run { send in
                    await send(.searchPilgrimagesResponse(filteredPilgrimages))
                    await send(.stopLoading)
                }

            case let .searchPilgrimagesResponse(filteredPilgrimages):
                // 検索結果を更新
                state.allSearchCandidatePilgrimages = filteredPilgrimages
                return .none
            }
        }
    }

    private func searchPilgrimages(with searchText: String, searchTarget: [PilgrimageInformation]) -> [PilgrimageInformation] {
        let normalizedSearchText = searchText.normalizedString
        return searchTarget.filter { pilgrimage in
            let normalizedSearchCandidates = pilgrimage.searchCandidateList.map { $0.normalizedString }

            // 部分一致を確認する
            let matchingCandidates = normalizedSearchCandidates.filter {
                $0.range(of: normalizedSearchText, options: .caseInsensitive) != nil
            }

            return !matchingCandidates.isEmpty
        }
    }
}


extension String {
    var normalizedString: String {
        return folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
