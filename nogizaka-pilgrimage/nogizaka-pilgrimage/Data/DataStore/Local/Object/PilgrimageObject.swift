//
//  PilgrimageObject.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/04.
//

import Foundation
import SwiftData

@Model
final class PilgrimageObject {
    @Attribute(.unique) var code: String
    var name: String
    var pilgrimageDescription: String
    var latitude: String
    var longitude: String
    var address: String
    var imageURLString: String?
    var copyright: String?
    var searchCandidateList: [String]
    var fetchedAt: Date

    init(from dto: PilgrimageDTO, fetchedAt: Date = .now) {
        self.code = dto.code
        self.name = dto.name
        self.pilgrimageDescription = dto.description
        self.latitude = dto.latitude
        self.longitude = dto.longitude
        self.address = dto.address
        self.imageURLString = dto.imageURL?.absoluteString
        self.copyright = dto.copyright
        self.searchCandidateList = dto.searchCandidateList
        self.fetchedAt = fetchedAt
    }

    func toDomain() -> PilgrimageEntity {
        PilgrimageEntity(
            code: code,
            name: name,
            description: pilgrimageDescription,
            latitude: latitude,
            longitude: longitude,
            address: address,
            imageURL: imageURLString.flatMap { URL(string: $0) },
            copyright: copyright,
            searchCandidateList: searchCandidateList
        )
    }
}
