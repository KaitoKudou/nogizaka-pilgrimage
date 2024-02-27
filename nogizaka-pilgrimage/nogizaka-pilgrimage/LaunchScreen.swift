//
//  LaunchScreen.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/28.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isLoading = true
    @Environment(\.theme) private var theme

    var body: some View {
        if isLoading {
            ZStack {
                ProgressView()
                    .controlSize(.large)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            MainView()
                .environment(\.theme, .system)
        }
    }
}

#Preview {
    LaunchScreen()
}
