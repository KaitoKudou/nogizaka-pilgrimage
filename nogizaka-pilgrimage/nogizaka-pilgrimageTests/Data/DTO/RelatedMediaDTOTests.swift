//
//  RelatedMediaDTOTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/31.
//

import Foundation
import Testing

@testable import nogizaka_pilgrimage

@Suite(.timeLimit(.minutes(1)))
struct RelatedMediaDTOTests {

    // MARK: - ヘルパー

    private static func mediaJSON(_ fields: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: fields)
    }

    private static func pilgrimageJSON(_ extra: [String: Any] = [:]) -> Data {
        let base: [String: Any] = [
            "code": "001",
            "name": "テストスポット",
            "description": "テスト",
            "latitude": "35.0",
            "longitude": "139.0",
            "address": "テスト住所",
            "search_candidate_list": [],
        ]
        return try! JSONSerialization.data(
            withJSONObject: base.merging(extra) { _, new in new }
        )
    }

    // MARK: - 単体デコード

    static let decodeCases: [(input: Data, expected: (name: String, contentType: String?, releaseLabel: String?))] = [
        (
            input: mediaJSON(["name": "シンクロニシティ", "content_type": "music", "release_label": "20thシングル 表題曲"]),
            expected: ("シンクロニシティ", "music", "20thシングル 表題曲")
        ),
        (
            input: mediaJSON(["name": "乃木坂工事中", "content_type": NSNull(), "release_label": NSNull()]),
            expected: ("乃木坂工事中", nil, nil)
        ),
        (
            input: mediaJSON(["name": "乃木坂工事中"]),
            expected: ("乃木坂工事中", nil, nil)
        ),
    ]

    @Test("RelatedMediaDTOのデコード", arguments: decodeCases)
    func decode(
        input: Data,
        expected: (name: String, contentType: String?, releaseLabel: String?)
    ) throws {
        let dto = try JSONDecoder().decode(RelatedMediaDTO.self, from: input)
        #expect(dto.name == expected.name)
        #expect(dto.contentType == expected.contentType)
        #expect(dto.releaseLabel == expected.releaseLabel)
    }

    // MARK: - 配列デコード

    static let arrayDecodeCases: [(input: Data, expectedCount: Int)] = [
        (
            input: try! JSONSerialization.data(withJSONObject: [
                ["name": "シンクロニシティ", "content_type": "music", "release_label": "20thシングル 表題曲"],
                ["name": "乃木坂工事中", "content_type": "video"],
            ]),
            expectedCount: 2
        ),
        (
            input: "[]".data(using: .utf8)!,
            expectedCount: 0
        ),
    ]

    @Test("配列としてのデコード", arguments: arrayDecodeCases)
    func decodeArray(input: Data, expectedCount: Int) throws {
        let dtos = try JSONDecoder().decode([RelatedMediaDTO].self, from: input)
        #expect(dtos.count == expectedCount)
    }

    // MARK: - PilgrimageDTO内のrelated_media

    static let pilgrimageDTOCases: [(input: Data, expectedFirstName: String?)] = [
        (
            input: pilgrimageJSON(["related_media": [
                ["name": "13日の金曜日 MV", "content_type": "music", "release_label": "24thシングル 表題曲"],
            ]]),
            expectedFirstName: "13日の金曜日 MV"
        ),
        (
            input: pilgrimageJSON(),
            expectedFirstName: nil
        ),
    ]

    @Test("PilgrimageDTO内のrelated_mediaデコード", arguments: pilgrimageDTOCases)
    func decodeInPilgrimageDTO(input: Data, expectedFirstName: String?) throws {
        let dto = try JSONDecoder().decode(PilgrimageDTO.self, from: input)
        #expect(dto.relatedMedia?.first?.name == expectedFirstName)
    }
}
