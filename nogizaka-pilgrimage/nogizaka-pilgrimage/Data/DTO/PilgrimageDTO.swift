//
//  PilgrimageDTO.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Foundation

struct PilgrimageDTO: Codable {
    let code: String
    let name: String
    let description: String
    let latitude: String
    let longitude: String
    let address: String
    let imageURL: URL?
    let copyright: String?
    let searchCandidateList: [String]
    let relatedMedia: [RelatedMediaDTO]?

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case description
        case latitude
        case longitude
        case address
        case imageURL = "image_url"
        case copyright
        case searchCandidateList = "search_candidate_list"
        case relatedMedia = "related_media"
    }

    init(from entity: PilgrimageEntity) {
        self.code = entity.code
        self.name = entity.name
        self.description = entity.description
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.address = entity.address
        self.imageURL = entity.imageURL
        self.copyright = entity.copyright
        self.searchCandidateList = entity.searchCandidateList
        if let media = entity.relatedMedia {
            self.relatedMedia = [RelatedMediaDTO(from: media)]
        } else {
            self.relatedMedia = nil
        }
    }
}
