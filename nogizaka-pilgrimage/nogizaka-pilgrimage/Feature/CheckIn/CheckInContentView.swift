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
            Image(.checkedIn)
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text(pilgrimageName)
                .font(theme.fonts.bodyMedium)
                .foregroundStyle(Color(.tabPrimary))
                .lineLimit(2)
        }
    }
}

#Preview {
    CheckInContentView(
        pilgrimageName: dummyPilgrimageList[0].name
    )
}
