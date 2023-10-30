//
//  PilgrimageListType.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/19.
//

import Foundation

enum PilgrimageListType: CaseIterable {
    case all
    case favorite

    var title: String {
        switch self {
        case .all:
            return R.string.localizable.list_type_all()

        case .favorite:
            return R.string.localizable.list_type_favorite()
        }
    }
}
