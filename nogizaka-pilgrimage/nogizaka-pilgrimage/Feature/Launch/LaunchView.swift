//
//  LaunchView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/25.
//

import SwiftUI

struct LaunchView: View {
    @Environment(\.openURL) private var openURL
    @State private var viewModel = LaunchViewModel()
    @State private var locationManager = LocationManager()
    @State private var isLocationReady = false

    var body: some View {
        if viewModel.isReady && isLocationReady {
            MainView(
                pilgrimages: viewModel.pilgrimages,
                initialLocation: locationManager.userLocation
            )
            .environment(\.theme, .system)
            .environment(locationManager)
            .fullScreenCover(isPresented: $viewModel.shouldShowSignInPromotion) {
                SignInPromotionView(context: .launch) { _ in
                    viewModel.dismissSignInPromotion()
                }
            }
        } else {
            ZStack {
                ProgressView()
                    .controlSize(.large)
            }
            .alert(
                viewModel.activeAlert?.title ?? "",
                isPresented: $viewModel.isAlertPresented,
                presenting: viewModel.activeAlert,
                actions: alertActions,
                message: alertMessage
            )
            .task {
                locationManager.requestLocationIfAuthorized()
                await viewModel.initialize()
                await locationManager.awaitLocation()
                isLocationReady = true
            }
        }
    }

    @ViewBuilder
    private func alertActions(for alertType: LaunchViewModel.AlertType) -> some View {
        switch alertType {
        case .updatePromotion(let info):
            if !info.isForce {
                Button(String(localized: .alertOptionalUpdate)) {
                    viewModel.dismissUpdate()
                }
            }
            Button(String(localized: .alertForceUpdate)) {
                openURL(URL(string: "https://apps.apple.com/jp/app/id6501994754")!)
                Task { await viewModel.initialize() }
            }
        case .fetchError, .networkError:
            Button(String(localized: .alertOk)) {
                Task { await viewModel.fetchAllPilgrimages() }
            }
        }
    }

    @ViewBuilder
    private func alertMessage(for alertType: LaunchViewModel.AlertType) -> some View {
        if case .updatePromotion(let info) = alertType {
            Text(info.message)
        }
    }
}

#Preview {
    LaunchView()
}
