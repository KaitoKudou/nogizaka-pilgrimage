//
//  PilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import SwiftUI

struct PilgrimageView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack {
            Text("PilgrimageView")
                .font(theme.fonts.title)
        }
        .navigationTitle(R.string.localizable.tabbar_pilgrimage())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PilgrimageView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageView()
    }
}
