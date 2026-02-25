//
//  LaunchViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/25.
//

import Dependencies
import FirebaseFirestore

@Observable
final class LaunchViewModel {
    @ObservationIgnored
    @Dependency(\.buildClient) var buildClient
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor

    var pilgrimages: [PilgrimageInformation] = []
    var isLoading = true
    var pendingUpdate: AppUpdateInformation?

    enum AlertType {
        case updatePromotion(AppUpdateInformation)
        case fetchError
        case networkError

        var title: String {
            switch self {
            case .updatePromotion(let info): return info.title
            case .fetchError: return APIError.fetchPilgrimagesError.localizedDescription
            case .networkError: return APIError.networkError.localizedDescription
            }
        }
    }
    var activeAlert: AlertType?
    var isAlertPresented: Bool {
        get { activeAlert != nil }
        set { if !newValue { activeAlert = nil } }
    }

    var isReady: Bool {
        !isLoading && !pilgrimages.isEmpty && pendingUpdate == nil
    }

    func initialize() async {
        await checkForUpdate()
        await fetchAllPilgrimages()
    }

    func fetchAllPilgrimages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await networkMonitor.monitorNetwork()

            let querySnapshot = try await Firestore.firestore()
                .collection("pilgrimage-list")
                .getDocuments()

            pilgrimages = try querySnapshot.documents
                .map { try $0.data(as: PilgrimageInformation.self) }
                .sorted { $0.code < $1.code }
        } catch {
            if (error as NSError).domain == FirestoreErrorDomain {
                activeAlert = .fetchError
            } else {
                activeAlert = .networkError
            }
        }
    }

    func dismissUpdate() {
        pendingUpdate = nil
    }

    private func checkForUpdate() async {
        do {
            try await networkMonitor.monitorNetwork()

            let appUpdateInfo = try await Firestore.firestore()
                .collection("configure")
                .document("update")
                .getDocument()
                .data(as: AppUpdateInformation.self)

            if appUpdateInfo.targetVersion.compare(buildClient.appVersion()) == .orderedDescending {
                pendingUpdate = appUpdateInfo
                activeAlert = .updatePromotion(appUpdateInfo)
            }
        } catch {
            activeAlert = .networkError
        }
    }
}
