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

    var body: some View {
        if viewModel.isReady {
            MainView(pilgrimages: viewModel.pilgrimages)
                .environment(\.theme, .system)
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
            .onAppear {
                Task { await viewModel.initialize() }
            }
        }
    }

    @ViewBuilder
    private func alertActions(for alertType: LaunchViewModel.AlertType) -> some View {
        switch alertType {
        case .updatePromotion(let info):
            if !info.isForce {
                Button(R.string.localizable.alert_optional_update()) {
                    viewModel.dismissUpdate()
                }
            }
            Button(R.string.localizable.alert_force_update()) {
                openURL(URL(string: "https://apps.apple.com/jp/app/id6501994754")!)
                Task { await viewModel.initialize() }
            }
        case .fetchError, .networkError:
            Button(R.string.localizable.alert_ok()) {
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
