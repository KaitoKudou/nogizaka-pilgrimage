//
//  MenuView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/19.
//

import LicenseList
import SwiftUI

struct MenuView: View {
    @State private var viewModel = MenuViewModel()
    @State private var navigationPath: [MenuDestination] = []
    @State private var safariURL: URL?

    private var sections: [(title: String, items: [MenuItem])] {
        [
            (
                String(localized: .menuSectionSupport),
                [.aboutDeveloper, .contact]
            ),
            (
                String(localized: .menuSectionApp),
                [.termsOfUse, .openSourceLicense, .iconLicense, .privacyPolicy, .appVersion(viewModel.appVersion)]
            )
        ]
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: .zero) {
                List {
                    accountSection

                    ForEach(sections, id: \.title) { section in
                        Section(section.title) {
                            ForEach(section.items, id: \.self) { item in
                                menuButton(for: item)
                            }
                        }
                    }
                }
                BannerViewContainer(adUnitID: .menu)
            }
            .navigationTitle(String(localized: .tabbarMenu))
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.primary)
            .navigationDestination(for: MenuDestination.self) { destination in
                switch destination {
                case .openSourceLicense:
                    LicenseListView()
                        .listStyle(.plain)
                        .navigationTitle(String(localized: .menuOpenSourceLicense))
                        .navigationBarTitleDisplayMode(.inline)
                case .iconLicense:
                    IconLicenseView()
                }
            }
        }
        .fullScreenCover(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .alert(
            viewModel.activeAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.activeAlert != nil },
                set: { if !$0 { viewModel.activeAlert = nil } }
            )
        ) {
            if viewModel.activeAlert == .signOutConfirmation {
                Button(String(localized: .menuSignOut), role: .destructive) {
                    viewModel.signOut()
                }
                Button(String(localized: .confirmationDialogCancel), role: .cancel) {}
            }
        }
        .task {
            await viewModel.observeAuthState()
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        Section(String(localized: .menuSectionAccount)) {
            switch viewModel.authState {
            case .unknown:
                ProgressView()
            case .signedOut:
                SignInWithAppleButtonWrapper(
                    isDisabled: viewModel.isSigningIn,
                    action: { await viewModel.signInWithApple() }
                )
            case .signedIn(let user):
                let displayName = user.displayName ?? user.email ?? String(localized: .menuSignedInFallback)
                Text(String(format: String(localized: .menuSignedInAs), displayName))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(String(localized: .menuSignOut), role: .destructive) {
                    viewModel.confirmSignOut()
                }
            }
        }
    }

    private func menuButton(for menuItem: MenuItem) -> some View {
        Button(menuItem.title) {
            guard let action = viewModel.action(for: menuItem) else { return }
            switch action {
            case .navigate(let destination):
                navigationPath.append(destination)
            case .openURL(let url):
                safariURL = url
            }
        }
    }
}

#Preview {
    MenuView()
}
