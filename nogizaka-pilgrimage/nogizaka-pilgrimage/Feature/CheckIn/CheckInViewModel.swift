//
//  CheckInViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/24.
//

import Dependencies
import Foundation

@Observable
final class CheckInViewModel {
    @ObservationIgnored
    @Dependency(CheckInRepository.self) var checkInRepository

    var checkedInPilgrimages: [PilgrimageEntity] = []
    var isLoading = false
    var alertMessage: String?
    var showAlert = false

    func fetchCheckedInPilgrimages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            checkedInPilgrimages = try await checkInRepository.fetchCheckedInPilgrimages()
        } catch is APIError {
            alertMessage = APIError.fetchError.localizedDescription
            showAlert = true
        } catch {
            alertMessage = APIError.unknownError.localizedDescription
            showAlert = true
        }
    }
}
