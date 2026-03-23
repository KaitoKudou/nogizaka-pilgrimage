//
//  CheckInDTO.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/23.
//

import Foundation

struct CheckInDTO: Codable {
    let pilgrimageDTO: PilgrimageDTO
    // TODO: UUID→Firebase Auth ID 移行完了後、レガシーデータがなくなった時点で非オプショナルにする
    let checkedInAt: Date?
    let memo: String?

    enum CodingKeys: String, CodingKey {
        case checkedInAt = "checked_in_at"
        case memo
    }

    init(pilgrimageDTO: PilgrimageDTO, checkedInAt: Date, memo: String?) {
        self.pilgrimageDTO = pilgrimageDTO
        self.checkedInAt = checkedInAt
        self.memo = memo
    }

    init(from decoder: Decoder) throws {
        pilgrimageDTO = try PilgrimageDTO(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        checkedInAt = try container.decodeIfPresent(Date.self, forKey: .checkedInAt)
        memo = try container.decodeIfPresent(String.self, forKey: .memo)
    }

    func encode(to encoder: Encoder) throws {
        try pilgrimageDTO.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(checkedInAt, forKey: .checkedInAt)
        try container.encodeIfPresent(memo, forKey: .memo)
    }
}
