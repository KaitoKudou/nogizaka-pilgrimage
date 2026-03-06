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

    private let adSize = BannerViewContainer.getAdSize(width: UIScreen.main.bounds.width)
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
                    ForEach(sections, id: \.title) { section in
                        Section(section.title) {
                            ForEach(section.items, id: \.self) { item in
                                menuButton(for: item)
                            }
                        }
                    }
                }
                BannerViewContainer(adUnitID: .menu)
                    .frame(width: adSize.size.width, height: adSize.size.height)
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
