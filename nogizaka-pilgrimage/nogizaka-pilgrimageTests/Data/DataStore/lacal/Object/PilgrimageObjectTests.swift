//
//  PilgrimageObjectTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/31.
//

import Foundation
import Testing

@testable import nogizaka_pilgrimage

@Suite(.timeLimit(.minutes(1)))
struct PilgrimageObjectTests {

    // MARK: - ヘルパー

    private static func pilgrimageJSON(_ extra: [String: Any] = [:]) -> Data {
        let base: [String: Any] = [
            "code": "001",
            "name": "テストスポット",
            "description": "テスト説明",
            "latitude": "35.0",
            "longitude": "139.0",
            "address": "テスト住所",
            "search_candidate_list": ["テスト"],
        ]
        return try! JSONSerialization.data(
            withJSONObject: base.merging(extra) { _, new in new }
        )
    }

    // MARK: - toDomain: relatedMedia

    static let toDomainCases: [(input: Data, expected: (name: String?, contentType: String?, releaseLabel: String?))] = [
        (
            input: pilgrimageJSON(["related_media": [
                ["name": "シンクロニシティ", "content_type": "music", "release_label": "20thシングル 表題曲"],
                ["name": "乃木坂工事中", "content_type": "video"],
            ]]),
            expected: ("シンクロニシティ", "music", "20thシングル 表題曲")
        ),
        (
            input: pilgrimageJSON(),
            expected: (nil, nil, nil)
        ),
        (
            input: pilgrimageJSON(["related_media": [] as [Any]]),
            expected: (nil, nil, nil)
        ),
    ]

    @Test("toDomainでrelatedMediaが正しく変換される", arguments: toDomainCases)
    func toDomain(
        input: Data,
        expected: (name: String?, contentType: String?, releaseLabel: String?)
    ) throws {
        let dto = try JSONDecoder().decode(PilgrimageDTO.self, from: input)
        let entity = PilgrimageObject(from: dto).toDomain()

        #expect(entity.relatedMedia?.name == expected.name)
        #expect(entity.relatedMedia?.contentType == expected.contentType)
        #expect(entity.relatedMedia?.releaseLabel == expected.releaseLabel)
    }
}
