//
//  PilgrimageListTypeSelectView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/20.
//

import SwiftUI

struct PilgrimageListTypeSelectView: View {
    @Environment(\.theme) private var theme
    @Binding var type: PilgrimageListType
    @State private var isAnimation = false
    let screenWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(spacing: screenWidth / 3) {
                ForEach(PilgrimageListType.allCases, id: \.self) { type in
                    Button {
                        self.type = type
                        isAnimation.toggle()
                    } label: {
                        Text(type.title)
                            .foregroundStyle(
                                self.type == type ?
                                R.color.text_secondary()!.color :
                                    R.color.nav_text()!.color
                            )
                            .font(theme.fonts.bodyLarge)
                    }
                }
            }
            .padding(.horizontal, theme.margins.spacing_xxl)

            Rectangle()
                .fill(R.color.text_secondary()!.color)
                .frame(width: buttonWidth(), height: 1.0)
                .offset(x: barOffset(), y: .zero)
                .animation(.linear(duration: 0.3), value: isAnimation)

            Divider()
        }
    }

    /// - Returns: ボタンの横幅
    private func buttonWidth() -> CGFloat {
        let width = (screenWidth - theme.margins.spacing_xxl * 2) / 2
        return max(0, width)
    }

    /// 選択状態を切り替えた際のバーの位置調整
    /// - Returns: バーをずらす量
    private func barOffset() -> CGFloat {
        switch type {
        case .all:
            return theme.margins.spacing_xs

        case .favorite:
            return screenWidth / 2 + (theme.margins.spacing_xs + theme.margins.spacing_l)
        }
    }
}

#Preview {
    PilgrimageListTypeSelectView(
        type: .constant(.favorite),
        screenWidth: UIScreen.main.bounds.width
    )
    .previewLayout(.sizeThatFits)
}