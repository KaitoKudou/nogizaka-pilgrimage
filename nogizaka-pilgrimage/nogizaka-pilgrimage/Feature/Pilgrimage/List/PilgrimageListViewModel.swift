//
//  PilgrimageListViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import Dependencies
import FirebaseFirestore
import UIKit

@Observable
final class PilgrimageListViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor

    var pilgrimages: [PilgrimageInformation] = []
    var searchResults: [PilgrimageInformation] = []
    var searchText = ""
    var isLoading = false
    var scrollToIndex = 0

    private var favoriteStatus: [Int: Bool] = [:]
    private var loadingItems: Set<Int> = []

    enum AlertType {
        case updateFavoritePilgrimagesError
        case networkError

        var title: String {
            switch self {
            case .updateFavoritePilgrimagesError: return APIError.updateFavoritePilgrimagesError.localizedDescription
            case .networkError: return APIError.networkError.localizedDescription
            }
        }
    }
    var activeAlert: AlertType?
    var isAlertPresented: Bool {
        get { activeAlert != nil }
        set { if !newValue { activeAlert = nil } }
    }

    func isFavorited(_ pilgrimage: PilgrimageInformation) -> Bool {
        favoriteStatus[pilgrimage.id] ?? false
    }

    func isItemLoading(_ pilgrimage: PilgrimageInformation) -> Bool {
        loadingItems.contains(pilgrimage.id)
    }

    func onAppear(pilgrimages: [PilgrimageInformation]) {
        self.pilgrimages = pilgrimages
        searchPilgrimages(searchText)
    }

    func searchPilgrimages(_ text: String) {
        isLoading = true
        defer { isLoading = false }

        if searchText != text {
            scrollToIndex = 0
        }
        searchText = text

        if text.isEmpty {
            searchResults = pilgrimages
        } else {
            let normalizedSearchText = text.normalizedString
            searchResults = pilgrimages.filter { pilgrimage in
                let normalizedSearchCandidates = pilgrimage.searchCandidateList.map { $0.normalizedString }
                return normalizedSearchCandidates.contains { candidate in
                    candidate.range(of: normalizedSearchText, options: .caseInsensitive) != nil
                }
            }
        }
    }

    func updateScrollToIndex(_ index: Int) {
        scrollToIndex = index
    }

    func verifyFavorited(pilgrimage: PilgrimageInformation) async {
        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore()
            .collection("favorite-list")
            .document(uuid)
            .collection("list")

        do {
            let documents = try await querySnapshot.getDocuments().documents
            favoriteStatus[pilgrimage.id] = documents.contains { $0.documentID == pilgrimage.name }
        } catch {
            // サイレントに失敗
        }
    }

    func toggleFavorite(pilgrimage: PilgrimageInformation) async {
        loadingItems.insert(pilgrimage.id)
        defer { loadingItems.remove(pilgrimage.id) }

        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
        let documentReference = querySnapshot.document(pilgrimage.name)

        do {
            try await networkMonitor.monitorNetwork()

            if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                try await documentReference.delete()
                favoriteStatus[pilgrimage.id] = false
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
                try await documentReference.setData(data as [String: Any])
                favoriteStatus[pilgrimage.id] = true
            }
        } catch let error as NSError where error.domain == FirestoreErrorDomain {
            activeAlert = .updateFavoritePilgrimagesError
        } catch {
            activeAlert = .networkError
        }
    }
}

extension String {
    var normalizedString: String {
        return folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
