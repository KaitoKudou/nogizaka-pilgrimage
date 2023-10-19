//
//  Theme.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/22.
//

import Foundation
import SwiftUI
import UIKit

struct Theme {
    let margins: Margins
    let fonts: Fonts
    let uiFonts: UIFonts

    /// デフォルトのテーマ
    static let system = Theme(margins: Margins(), fonts: Fonts(), uiFonts: UIFonts())
}

extension Theme {
    struct Margins {
        /// 0pt
        let zero: CGFloat = 0

        /// 4pt
        let spacing_xxs: CGFloat = 4

        /// 8pt
        let spacing_xs: CGFloat = 8

        /// 12pt
        let spacing_s: CGFloat = 12

        /// 16pt
        let spacing_m: CGFloat = 16

        /// 20pt
        let spacing_l: CGFloat = 20

        /// 32pt
        let spacing_xl: CGFloat = 32

        /// 40pt
        let spacing_xxl: CGFloat = 40
    }
}

extension Theme {
    struct Fonts {
        /// Title / 大見出し
        let title = Font.system(size: 20, weight: .bold)
        /// BodyLarge / 本文(大)
        let bodyLarge = Font.system(size: 18)
        /// BodyMedium / 本文(中)
        let bodyMedium = Font.system(size: 16)
        /// CaptionMedium/  注釈・補足文
        let caption = Font.system(size: 12)
    }

    struct UIFonts {
        /// Title / 大見出し
        let title = UIFont.systemFont(ofSize: 20, weight: .bold)
        /// NavigationTitle
        let navigationTitle = UIFont.systemFont(ofSize: 17, weight: .bold)
        /// BodyLarge / 本文(大)
        let bodyLarge = UIFont.systemFont(ofSize: 18)
        /// BodyMedium / 本文(中)
        let bodyMedium = UIFont.systemFont(ofSize: 16)
        /// CaptionMedium/  注釈・補足文
        let caption = UIFont.systemFont(ofSize: 12)
    }
}
