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
        VStack {
            Text("CheckInView")
                .font(theme.fonts.bodyMedium)
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
