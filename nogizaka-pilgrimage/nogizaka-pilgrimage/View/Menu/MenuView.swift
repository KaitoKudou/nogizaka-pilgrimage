//
//  MenuView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/07.
//

import ComposableArchitecture
import SwiftUI

enum MenuItem: Hashable {
    case contact
    case termsOfUse
    case privacyPolicy
    case appVersion(String)

    var title: String {
        switch self {
        case .contact: return R.string.localizable.menu_contact()
        case .termsOfUse: return R.string.localizable.menu_terms()
        case .privacyPolicy: return R.string.localizable.menu_privacy_policy()
        case .appVersion(let version): return R.string.localizable.menu_app_version(version)
        }
    }
}

struct MenuView: View {
    @Environment(\.theme) private var theme
    @State private var store = Store(
        initialState: MenuFeature.State()
    ) {
        MenuFeature()
    }
    private var menuList: [MenuItem] = []
    private let adSize = BannerView.getAdSize(width: UIScreen.main.bounds.width)

    init() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        menuList = [.contact, .termsOfUse, .privacyPolicy, .appVersion(appVersion)]
    }

    var body: some View {
        VStack {
            List {
                ForEach(menuList, id: \.self) { menuItem in
                    Button(menuItem.title) {
                        store.send(.view(menuItem))
                    }
                }
            }

            BannerView(adUnitID: .menu)
                .frame(
                    width: adSize.size.width,
                    height: adSize.size.height
                )
        }
        .listStyle(.plain)
        .navigationTitle(R.string.localizable.tabbar_menu())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MenuView()
}
