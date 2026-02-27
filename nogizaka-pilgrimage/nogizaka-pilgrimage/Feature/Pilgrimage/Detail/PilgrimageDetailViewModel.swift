//
//  PilgrimageDetailViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import CoreLocation
import Dependencies
import FirebaseFirestore
import UIKit

@Observable
final class PilgrimageDetailViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor

    var isLoading = false
    var favorited = false
    var hasCheckedIn = false

    enum AlertType {
        case notNearbyError
        case updateCheckedInError
        case updateFavoritePilgrimagesError
        case networkError

        var title: String {
            switch self {
            case .notNearbyError: return R.string.localizable.alert_not_nearby()
            case .updateCheckedInError: return APIError.updateCheckedInError.localizedDescription
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
        async let fav: () = verifyFavorited(pilgrimage)
        async let check: () = verifyCheckedIn(pilgrimage)
        _ = await (fav, check)
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

    func checkIn(pilgrimage: PilgrimageInformation, userCoordinate: CLLocationCoordinate2D) async {
        guard isNearbyPilgrimage(userCoordinate: userCoordinate, pilgrimageCoordinate: pilgrimage.coordinate) else {
            activeAlert = .notNearbyError
            return
        }

        isLoading = true
        defer { isLoading = false }

        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore().collection("checked-in-list").document(uuid).collection("list")
        let documentReference = querySnapshot.document(pilgrimage.name)

        do {
            if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                hasCheckedIn = false
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
                hasCheckedIn = true
            }
        } catch let error as NSError where error.domain == FirestoreErrorDomain {
            activeAlert = .updateCheckedInError
        } catch {
            activeAlert = .networkError
        }
    }

    private func verifyFavorited(_ pilgrimage: PilgrimageInformation) async {
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

    private func verifyCheckedIn(_ pilgrimage: PilgrimageInformation) async {
        let uuid = await UIDevice.current.identifierForVendor!.uuidString
        let querySnapshot = Firestore.firestore()
            .collection("checked-in-list")
            .document(uuid)
            .collection("list")

        do {
            let documents = try await querySnapshot.getDocuments().documents
            hasCheckedIn = documents.contains { $0.documentID == pilgrimage.name }
        } catch {
            // サイレントに失敗
        }
    }

    private func isNearbyPilgrimage(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D) -> Bool {
        let distanceThreshold = 200.0
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)
        return userLocation.distance(from: pilgrimageLocation) < distanceThreshold
    }
}
