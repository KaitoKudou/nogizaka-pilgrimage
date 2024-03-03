//
//  MainView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Environment(\.theme) private var theme
    @StateObject private var locationManager = LocationManager()
    @State private var store = Store(
        initialState: PilgrimageDetailFeature.State(
            favoriteState: FavoriteFeature.State(),
            checkInState: CheckInFeature.State()
        )
    ) {
        PilgrimageDetailFeature()
    }
    let pilgrimages: [PilgrimageInformation]

    var body: some View {
        TabView {
            NavigationStack {
                PilgrimageView(pilgrimages: pilgrimages)
            }
            .environmentObject(locationManager)
            .tabItem {
                Image(systemName: "map")
                Text(R.string.localizable.tabbar_pilgrimage())
            }

            NavigationStack {
                FavoritePilgrimageView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text(R.string.localizable.tabbar_favorite())
            }
            .environmentObject(locationManager)

            NavigationStack {
                CheckInView(store: store)
            }
            .tabItem {
                Image(R.image.icn_check_in.name)
                Text(R.string.localizable.tabbar_check_in())
            }

            NavigationStack {
                MenuView()
            }
            .tabItem {
                Image(systemName: "line.3.horizontal")
                Text(R.string.localizable.tabbar_menu())
            }
        }
        .onAppear {
            theme.styleTabBarGlobalAppearance()
            theme.styleNavigationBarGlobalAppearance()
        }
    }
}

#Preview {
    MainView(pilgrimages: dummyPilgrimageList)
}
