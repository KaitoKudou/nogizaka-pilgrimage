//
//  MainView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import CoreLocation
import SwiftUI

struct MainView: View {
    @Environment(\.theme) private var theme
    @Environment(LocationManager.self) private var locationManager
    let pilgrimages: [PilgrimageEntity]
    let initialLocation: CLLocationCoordinate2D?
    #if DEBUG
    @State private var showDebugMenu = false
    #endif

    var body: some View {
        TabView {
            NavigationStack {
                PilgrimageView(pilgrimages: pilgrimages, initialLocation: initialLocation)
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
        #if DEBUG
        .onShake {
            showDebugMenu = true
        }
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuView()
        }
        #endif
    }
}

#Preview {
    MainView(pilgrimages: dummyPilgrimageList, initialLocation: nil)
        .environment(LocationManager())
}
