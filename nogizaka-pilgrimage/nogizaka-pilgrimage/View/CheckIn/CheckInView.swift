//
//  CheckInView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))], spacing: theme.margins.spacing_s) {

                    // TODO: - dummyPilgrimageListを本番用の配列に置き換える
                    ForEach(dummyPilgrimageList, id: \.self) { pilgrimage in
                        CheckInContentView(pilgrimageName: pilgrimage.name)
                    }
                }
                .padding(.top, theme.margins.spacing_xs)
            }
        }
        .navigationTitle(R.string.localizable.tabbar_check_in())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CheckInView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInView()
    }
}
