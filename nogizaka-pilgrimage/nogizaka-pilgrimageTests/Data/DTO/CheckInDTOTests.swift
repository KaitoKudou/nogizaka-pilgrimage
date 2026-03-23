//
//  CheckInDTOTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/23.
//

import Foundation
import Testing

@testable import nogizaka_pilgrimage

@Suite(.timeLimit(.minutes(1)))
struct CheckInDTOTests {
    
    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    
    private static func jsonData(_ extra: [String: Any] = [:]) -> Data {
        let base: [String: Any] = [
            "code": "001",
            "name": "乃木坂駅",
            "description": "テスト",
            "latitude": "35.666827",
            "longitude": "139.726497",
            "address": "東京都港区",
            "search_candidate_list": ["乃木坂駅"],
        ]
        return try! JSONSerialization.data(
            withJSONObject: base.merging(extra) { _, new in new }
        )
    }
    
    static let testCases: [(input: Data, expected: (code: String, checkedInAt: Date?, memo: String?))] = [
        (
            input: jsonData(),
            expected: ("001", nil, nil)
        ),
        (
            input: jsonData([
                "checked_in_at": fixedDate.timeIntervalSince1970,
                "memo": "発車メロディ流れてた",
            ]),
            expected: ("001", fixedDate, "発車メロディ流れてた")
        ),
    ]
    
    // MARK: - デコード

    @Test("CheckInDTOのデコード", arguments: testCases)
    func decode(
        input: Data,
        expected: (code: String, checkedInAt: Date?, memo: String?)
    ) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let dto = try decoder.decode(CheckInDTO.self, from: input)

        #expect(dto.pilgrimageDTO.code == expected.code)
        #expect(dto.checkedInAt == expected.checkedInAt)
        #expect(dto.memo == expected.memo)
    }

    // MARK: - ラウンドトリップ（encode → decode）

    @Test("encode→decodeでフィールドが保持される")
    func roundTrip() throws {
        let original = CheckInDTO(
            pilgrimageDTO: PilgrimageDTO(from: dummyPilgrimageList[0]),
            checkedInAt: Self.fixedDate,
            memo: "テストメモ"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(CheckInDTO.self, from: data)

        #expect(decoded.pilgrimageDTO.code == original.pilgrimageDTO.code)
        #expect(decoded.pilgrimageDTO.name == original.pilgrimageDTO.name)
        #expect(decoded.checkedInAt == original.checkedInAt)
        #expect(decoded.memo == original.memo)
    }
}
