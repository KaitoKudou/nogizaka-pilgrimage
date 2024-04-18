//
//  CheckInContentView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/19.
//

import SwiftUI

struct CheckInContentView: View {
    @Environment(\.theme) private var theme
    let pilgrimageName: String

    var body: some View {
        VStack {
            Image(R.image.checked_in_image.name)
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text(pilgrimageName)
                .font(theme.fonts.bodyMedium)
                .foregroundColor(R.color.tab_primary()!.color)
                .lineLimit(2)
        }
    }
}

#Preview {
    CheckInContentView(
        pilgrimageName: dummyPilgrimageList[0].name
    )
}
