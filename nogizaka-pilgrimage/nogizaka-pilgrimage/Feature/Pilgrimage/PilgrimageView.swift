//
//  PilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import AppTrackingTransparency
import CoreLocation
import SwiftUI

struct PilgrimageView: View {
    let pilgrimages: [PilgrimageEntity]
    let initialLocation: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            PilgrimageMapView(pilgrimages: pilgrimages, initialLocation: initialLocation)
        }
        .navigationTitle(String(localized: .tabbarPilgrimage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            pilgrimageListToolBarItem
        }
        .onDisappear {
            requestTrackingAuthorization()
        }
    }

    private func requestTrackingAuthorization() {
        Task {
            // ATTダイアログは画面遷移直後に表示するとシステムに無視される場合があるため、1秒遅延させる
            try? await Task.sleep(for: .seconds(1))
            await ATTrackingManager.requestTrackingAuthorization()
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
    PilgrimageView(pilgrimages: dummyPilgrimageList, initialLocation: nil)
        .environment(LocationManager())
}
