//
//  Rswift+Sendable.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/06.
//

import Rswift

// TODO: R.swift を剥がす際にこのファイルも削除する
extension Rswift.ColorResource: @retroactive @unchecked Sendable {}
extension Rswift.FileResource: @retroactive @unchecked Sendable {}
extension Rswift.ImageResource: @retroactive @unchecked Sendable {}
extension Rswift.StringResource: @retroactive @unchecked Sendable {}
