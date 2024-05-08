//
//  LaunchScreen.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/28.
//

import ComposableArchitecture
import SwiftUI

struct LaunchScreen: View {
    @State var store = Store(
        initialState: InitialFeature.State()
    ) {
        InitialFeature()
    }

    var body: some View {
        if store.isLoading || store.hasError || store.shouldUpdate {
            ZStack {
                ProgressView()
                    .controlSize(.large)
            }
            .alert(
                $store.scope(
                    state: \.destination?.alert,
                    action: \.destination.alert
                )
            )
            .onAppear {
                store.send(.onAppear)
            }
        } else {
            if !store.hasError {
                MainView(pilgrimages: store.pilgrimages)
                    .environment(\.theme, .system)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
