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
    var relatedMediaName: String?
    var relatedMediaContentType: String?
    var relatedMediaReleaseLabel: String?
    var fetchedAt: Date

    init(from dto: PilgrimageDTO, fetchedAt: Date = .now) {
        let firstMedia = dto.relatedMedia?.first

        self.code = dto.code
        self.name = dto.name
        self.pilgrimageDescription = dto.description
        self.latitude = dto.latitude
        self.longitude = dto.longitude
        self.address = dto.address
        self.imageURLString = dto.imageURL?.absoluteString
        self.copyright = dto.copyright
        self.searchCandidateList = dto.searchCandidateList
        self.relatedMediaName = firstMedia?.name
        self.relatedMediaContentType = firstMedia?.contentType
        self.relatedMediaReleaseLabel = firstMedia?.releaseLabel
        self.fetchedAt = fetchedAt
    }

    func toDomain() -> PilgrimageEntity {
        var relatedMedia: RelatedMediaEntity?
        if let relatedMediaName {
            relatedMedia = RelatedMediaEntity(
                name: relatedMediaName,
                contentType: relatedMediaContentType,
                releaseLabel: relatedMediaReleaseLabel
            )
        }

        return PilgrimageEntity(
            code: code,
            name: name,
            description: pilgrimageDescription,
            latitude: latitude,
            longitude: longitude,
            address: address,
            imageURL: imageURLString.flatMap { URL(string: $0) },
            copyright: copyright,
            searchCandidateList: searchCandidateList,
            relatedMedia: relatedMedia
        )
    }
}
