//
//  PilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import AppTrackingTransparency
import ComposableArchitecture
import SwiftUI

struct PilgrimageView: View {
    let pilgrimages: [PilgrimageInformation]

    var body: some View {
        ZStack {
            PilgrimageMapView(pilgrimages: pilgrimages)
        }
        .navigationTitle(R.string.localizable.tabbar_pilgrimage())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            pilgrimageListToolBarItem
        }
        .onAppear {
            requestTrackingAuthorization()
        }
    }

    private func requestTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
    }
}

// MARK: Extension PilgrimageView
extension PilgrimageView {
    /// NavigationBarの聖地一覧遷移ボタン
    private var pilgrimageListToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(
                destination:
                    PilgrimageListView(pilgrimages: pilgrimages)
            ) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    PilgrimageView(
        pilgrimages: dummyPilgrimageList
    )
    .environmentObject(LocationManager())
}
