//
//  MainView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import SwiftUI

struct MainView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        TabView {
            NavigationStack {
                PilgrimageView()
            }
            .tabItem {
                Image(systemName: "map")
                Text(R.string.localizable.tabbar_pilgrimage())
            }

            NavigationStack {
                CheckInView()
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
