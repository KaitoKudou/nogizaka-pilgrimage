//
//  CheckInViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/24.
//

import FirebaseFirestore
import Foundation
import UIKit

@Observable
final class CheckInViewModel {
    var checkedInPilgrimages: [PilgrimageInformation] = []
    var isLoading = false
    var alertMessage: String?
    var showAlert = false

    func fetchCheckedInPilgrimages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let uuid = await UIDevice.current.identifierForVendor!.uuidString
            let querySnapshot = try await Firestore.firestore()
                .collection("checked-in-list")
                .document(uuid)
                .collection("list")
                .getDocuments()

            checkedInPilgrimages = try querySnapshot.documents.map {
                try $0.data(as: PilgrimageInformation.self)
            }
        } catch {
            if (error as NSError).domain == FirestoreErrorDomain {
                alertMessage = APIError.fetchCheckedInError.localizedDescription
            } else {
                alertMessage = APIError.unknownError.localizedDescription
            }
            showAlert = true
        }
    }
}
