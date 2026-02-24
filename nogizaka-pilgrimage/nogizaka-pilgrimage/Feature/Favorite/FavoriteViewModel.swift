//
//  FavoriteViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/24.
//

import Dependencies
import FirebaseFirestore

@Observable
final class FavoriteViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor

    var favoritePilgrimages: [PilgrimageInformation] = []
    var isLoading = false
    var alertMessage: String?
    var showAlert = false
    var scrollToIndex = 0

    private var loadingItems: Set<Int> = []

    func isItemLoading(_ pilgrimage: PilgrimageInformation) -> Bool {
        loadingItems.contains(pilgrimage.id)
    }

    func fetchFavorites() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await networkMonitor.monitorNetwork()

            let uuid = await UIDevice.current.identifierForVendor!.uuidString
            let querySnapshot = try await Firestore.firestore()
                .collection("favorite-list")
                .document(uuid)
                .collection("list")
                .getDocuments()

            favoritePilgrimages = try querySnapshot.documents.map {
                try $0.data(as: PilgrimageInformation.self)
            }
        } catch {
            if (error as NSError).domain == FirestoreErrorDomain {
                alertMessage = APIError.fetchFavoritePilgrimagesError.localizedDescription
            } else {
                alertMessage = APIError.unknownError.localizedDescription
            }
            showAlert = true
        }
    }

    func toggleFavorite(_ pilgrimage: PilgrimageInformation) async {
        loadingItems.insert(pilgrimage.id)
        defer { loadingItems.remove(pilgrimage.id) }

        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let collection = Firestore.firestore()
            .collection("favorite-list")
            .document(uuid)
            .collection("list")
        let documentRef = collection.document(pilgrimage.name)

        do {
            try await networkMonitor.monitorNetwork()

            if (try await collection.getDocuments().documents
                .first(where: { $0.documentID == pilgrimage.name })) != nil {
                try await documentRef.delete()
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
                try await documentRef.setData(data as [String: Any])
            }
            await fetchFavorites()
        } catch {
            if (error as NSError).domain == FirestoreErrorDomain {
                alertMessage = APIError.updateFavoritePilgrimagesError.localizedDescription
            } else {
                alertMessage = APIError.unknownError.localizedDescription
            }
            showAlert = true
        }
    }
}
