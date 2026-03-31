//
//  RelatedMediaDTO.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/30.
//

import Foundation

struct RelatedMediaDTO: Codable {
    let name: String
    let contentType: String?
    let releaseLabel: String?

    enum CodingKeys: String, CodingKey {
        case name
        case contentType = "content_type"
        case releaseLabel = "release_label"
    }

    init(from media: RelatedMediaEntity) {
        self.name = media.name
        self.contentType = media.contentType
        self.releaseLabel = media.releaseLabel
    }
}
