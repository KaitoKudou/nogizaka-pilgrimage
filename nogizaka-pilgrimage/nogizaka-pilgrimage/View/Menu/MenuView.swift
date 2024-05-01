//
//  MenuView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/07.
//

import ComposableArchitecture
import LicenseList
import SwiftUI

enum MenuItem: Hashable {
    case aboutDeveloper
    case contact
    case termsOfUse
    case openSourceLicense
    case iconLicense
    case privacyPolicy
    case appVersion(String)

    var title: String {
        switch self {
        case .aboutDeveloper: return R.string.localizable.menu_about_developer()
        case .contact: return R.string.localizable.menu_contact()
        case .termsOfUse: return R.string.localizable.menu_terms()
        case .openSourceLicense: return R.string.localizable.menu_open_source_license()
        case .iconLicense: return R.string.localizable.menu_icon_license()
        case .privacyPolicy: return R.string.localizable.menu_privacy_policy()
        case .appVersion(let version): return R.string.localizable.menu_app_version(version)
        }
    }
}

struct MenuView: View {
    enum MenuSection: Hashable, CaseIterable {
        case support
        case aboutApp

        var title: String {
            switch self {
            case .support: return R.string.localizable.menu_section_support()
            case .aboutApp: return R.string.localizable.menu_section_app()
            }
        }
    }

    @Environment(\.theme) private var theme
    @Bindable var store: StoreOf<MenuFeature>
    @State private var menuItems: [MenuSection: [MenuItem]] = [:]
    private let adSize = BannerView.getAdSize(width: UIScreen.main.bounds.width)

    init(store: StoreOf<MenuFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: .zero) {
                List {
                    ForEach(MenuSection.allCases, id: \.self) { section in
                        Section(section.title) {
                            ForEach(menuItems[section] ?? [], id: \.self) { menuItem in
                                Button(menuItem.title) {
                                    store.send(.view(menuItem))
                                }
                            }
                        }
                    }
                }

                BannerView(adUnitID: .menu)
                    .frame(
                        width: adSize.size.width,
                        height: adSize.size.height
                    )
            }
            .navigationTitle(R.string.localizable.tabbar_menu())
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.primary)
        } destination: { store in
            switch store.state {
            case .openSourceLicense:
                LicenseListView()
                    .listStyle(.plain)
                    .navigationTitle(R.string.localizable.menu_open_source_license())
                    .navigationBarTitleDisplayMode(.inline)
            case .iconLicense:
                IconLicenseView(
                    store: .init(
                        initialState: IconLicenseFeature.State()
                    ) {
                        IconLicenseFeature()
                    }
                )
            }
        }
        .onAppear {
            store.send(.onAppear)
            setupMenuItems()
        }
    }

    private func setupMenuItems() {
        let appVersion = store.appVersion
        menuItems[.support] = [.aboutDeveloper, .contact]
        menuItems[.aboutApp] = [.termsOfUse, .openSourceLicense, .iconLicense, .privacyPolicy, .appVersion(appVersion)]
    }
}

#Preview {
    MenuView(
        store: .init(
            initialState: MenuFeature.State()
        ) {
            MenuFeature()
        }
    )
}
