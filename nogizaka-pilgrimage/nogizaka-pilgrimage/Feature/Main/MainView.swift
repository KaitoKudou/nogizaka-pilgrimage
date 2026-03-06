//
//  MainView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import SwiftUI

struct MainView: View {
    @Environment(\.theme) private var theme
    @State private var locationManager = LocationManager()
    let pilgrimages: [PilgrimageEntity]

    var body: some View {
        TabView {
            NavigationStack {
                PilgrimageView(pilgrimages: pilgrimages)
            }
            .environment(locationManager)
            .tabItem {
                Image(systemName: "map")
                Text(.tabbarPilgrimage)
            }

            NavigationStack {
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text(.tabbarFavorite)
            }
            .environment(locationManager)

            NavigationStack {
                CheckInView()
            }
            .tabItem {
                Image(.stamp)
                Text(.tabbarCheckIn)
            }

            MenuView()
            .tabItem {
                Image(systemName: "line.3.horizontal")
                Text(.tabbarMenu)
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
