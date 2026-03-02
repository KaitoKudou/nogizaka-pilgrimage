//
//  MenuView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/19.
//

import Dependencies
import LicenseList
import SwiftUI

struct MenuView: View {
    @Dependency(\.safari) private var safari

    @State private var viewModel = MenuViewModel()
    @State private var navigationPath: [MenuDestination] = []

    private let adSize = BannerViewContainer.getAdSize(width: UIScreen.main.bounds.width)
    private var sections: [(title: String, items: [MenuItem])] {
        [
            (
                R.string.localizable.menu_section_support(),
                [.aboutDeveloper, .contact]
            ),
            (
                R.string.localizable.menu_section_app(),
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
            .navigationTitle(R.string.localizable.tabbar_menu())
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.primary)
            .navigationDestination(for: MenuDestination.self) { destination in
                switch destination {
                case .openSourceLicense:
                    LicenseListView()
                        .listStyle(.plain)
                        .navigationTitle(R.string.localizable.menu_open_source_license())
                        .navigationBarTitleDisplayMode(.inline)
                case .iconLicense:
                    IconLicenseView()
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
                Task { await safari(url) }
            }
        }
    }
}

#Preview {
    MenuView()
}
