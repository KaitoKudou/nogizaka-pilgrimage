//
//  PilgrimageCardViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import Dependencies
import FirebaseFirestore
import UIKit

@Observable
final class PilgrimageCardViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(\.routeActionClient) var routeActionClient

    var isLoading = false
    var favorited = false

    var isConfirmationDialogPresented = false
    private(set) var routeLatitude = ""
    private(set) var routeLongitude = ""

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

    func onAppear(pilgrimage: PilgrimageInformation) async {
        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore()
            .collection("favorite-list")
            .document(uuid)
            .collection("list")

        do {
            let documents = try await querySnapshot.getDocuments().documents
            favorited = documents.contains { $0.documentID == pilgrimage.name }
        } catch {
            // サイレントに失敗
        }
    }

    func toggleFavorite(_ pilgrimage: PilgrimageInformation) async {
        isLoading = true
        defer { isLoading = false }

        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore().collection("favorite-list").document(uuid).collection("list")
        let documentReference = querySnapshot.document(pilgrimage.name)

        do {
            try await networkMonitor.monitorNetwork()

            if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                try await documentReference.delete()
                favorited = false
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
                favorited = true
            }
        } catch let error as NSError where error.domain == FirestoreErrorDomain {
            activeAlert = .updateFavoritePilgrimagesError
        } catch {
            activeAlert = .networkError
        }
    }

    func showRouteDialog(latitude: String, longitude: String) {
        routeLatitude = latitude
        routeLongitude = longitude
        isConfirmationDialogPresented = true
    }

    func openAppleMaps() async {
        await routeActionClient.viewOnMap(routeLatitude, routeLongitude)
    }

    func openGoogleMaps() async {
        await routeActionClient.viewOnGoogleMaps(routeLatitude, routeLongitude)
    }
}
