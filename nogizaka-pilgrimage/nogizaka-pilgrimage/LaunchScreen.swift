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
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.state.isLoading || viewStore.state.hasError {
                ZStack {
                    ProgressView()
                        .controlSize(.large)
                }
                .alert(store: store.scope(state: \.$alert, action: InitialFeature.Action.alertDismissed))
                .onAppear {
                    store.send(.fetchAllPilgrimage)
                }
            } else {
                if !viewStore.state.hasError {
                    MainView()
                        .environment(\.theme, .system)
                }
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
