//
//  PilgrimageMapViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/22.
//

import CoreLocation
import Testing

@testable import nogizaka_pilgrimage

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct PilgrimageMapViewModelTests {

    // MARK: - テスト用データ

    /// 乃木坂駅（code: 130001）を含むリスト
    private static let listWithNogizaka: [PilgrimageEntity] = [
        dummyPilgrimageList[0], // 001: 乃木坂駅（dummy）
        dummyPilgrimageList[1], // 002: 乃木神社
        makePilgrimage(code: "130001", name: "乃木坂駅", latitude: "35.666827", longitude: "139.726497"),
        dummyPilgrimageList[2], // 003: 渋谷駅
    ]

    private static func makePilgrimage(
        code: String,
        name: String,
        latitude: String,
        longitude: String
    ) -> PilgrimageEntity {
        PilgrimageEntity(
            code: code,
            name: name,
            description: "",
            latitude: latitude,
            longitude: longitude,
            address: "",
            imageURL: nil,
            copyright: nil,
            searchCandidateList: []
        )
    }

    // MARK: - defaultIndex

    @Test("乃木坂駅(130001)が含まれるリストではそのインデックスを返す")
    func defaultIndex_withNogizakaStation() {
        let index = PilgrimageMapViewModel.defaultIndex(for: Self.listWithNogizaka)
        #expect(index == 2)
    }

    @Test("乃木坂駅(130001)が含まれないリストでは0を返す")
    func defaultIndex_withoutNogizakaStation() {
        let index = PilgrimageMapViewModel.defaultIndex(for: dummyPilgrimageList)
        #expect(index == 0)
    }

    @Test("空リストでは0を返す")
    func defaultIndex_emptyList() {
        let index = PilgrimageMapViewModel.defaultIndex(for: [])
        #expect(index == 0)
    }

    // MARK: - nearestPilgrimageIndex

    @Test("乃木坂駅の座標ではindex 0を返す")
    func nearestIndex_nearNogizakaStation() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let index = viewModel.nearestPilgrimageIndex(
            from: CLLocationCoordinate2D(latitude: 35.666827, longitude: 139.726497)
        )
        #expect(index == 0)
    }

    @Test("秋葉原UDX付近の座標ではindex 4を返す")
    func nearestIndex_nearAkihabaraUDX() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let index = viewModel.nearestPilgrimageIndex(
            from: CLLocationCoordinate2D(latitude: 35.700, longitude: 139.773)
        )
        #expect(index == 4)
    }

    @Test("渋谷駅付近の座標ではindex 2を返す")
    func nearestIndex_nearShibuyaStation() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let index = viewModel.nearestPilgrimageIndex(
            from: CLLocationCoordinate2D(latitude: 35.658, longitude: 139.702)
        )
        #expect(index == 2)
    }

    @Test("空のpilgrimagesでは0を返す")
    func nearestIndex_emptyPilgrimages() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: [])
        let index = viewModel.nearestPilgrimageIndex(
            from: CLLocationCoordinate2D(latitude: 35.0, longitude: 139.0)
        )
        #expect(index == 0)
    }

    @Test("同距離の聖地が複数ある場合、先頭のインデックスを返す")
    func nearestIndex_equidistant_returnsFirst() {
        let equidistantList = [
            Self.makePilgrimage(code: "001", name: "A", latitude: "35.0", longitude: "139.0"),
            Self.makePilgrimage(code: "002", name: "B", latitude: "35.0", longitude: "139.0"),
        ]
        let viewModel = PilgrimageMapViewModel(pilgrimages: equidistantList)
        let index = viewModel.nearestPilgrimageIndex(
            from: CLLocationCoordinate2D(latitude: 35.0, longitude: 139.0)
        )
        #expect(index == 0)
    }

    // MARK: - selectNearestPilgrimageIfNeeded

    @Test("位置情報ありでselectedIndexが更新されtrueを返す")
    func selectNearest_withLocation_updatesIndex() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let nearAkihabara = CLLocationCoordinate2D(latitude: 35.700, longitude: 139.773)
        let changed = viewModel.selectNearestPilgrimageIfNeeded(userLocation: nearAkihabara)
        #expect(changed == true)
        #expect(viewModel.selectedIndex == 4)
    }

    @Test("2回呼び出すと2回目はfalseを返しindexは変わらない")
    func selectNearest_calledTwice_onlyUpdatesOnce() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let nearAkihabara = CLLocationCoordinate2D(latitude: 35.700, longitude: 139.773)
        let nearShibuya = CLLocationCoordinate2D(latitude: 35.658, longitude: 139.702)

        viewModel.selectNearestPilgrimageIfNeeded(userLocation: nearAkihabara)
        let secondResult = viewModel.selectNearestPilgrimageIfNeeded(userLocation: nearShibuya)

        #expect(secondResult == false)
        #expect(viewModel.selectedIndex == 4)
    }

    @Test("userLocationがnilの場合falseを返しindexは変わらない")
    func selectNearest_nilLocation_doesNothing() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let initialIndex = viewModel.selectedIndex
        let changed = viewModel.selectNearestPilgrimageIfNeeded(userLocation: nil)
        #expect(changed == false)
        #expect(viewModel.selectedIndex == initialIndex)
    }

    @Test("最寄りがデフォルトと同じ場合falseを返す")
    func selectNearest_sameAsDefault_returnsFalse() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        // dummyListのデフォルトはindex 0（乃木坂駅 code:001）
        let nearNogizaka = CLLocationCoordinate2D(latitude: 35.666827, longitude: 139.726497)
        let changed = viewModel.selectNearestPilgrimageIfNeeded(userLocation: nearNogizaka)
        #expect(changed == false)
        #expect(viewModel.selectedIndex == 0)
    }

    // MARK: - init

    @Test("dummyListで初期化するとdefaultIndexと一致する")
    func init_setsDefaultIndex() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        let expected = PilgrimageMapViewModel.defaultIndex(for: dummyPilgrimageList)
        #expect(viewModel.selectedIndex == expected)
    }

    @Test("selectedIndexを更新できる")
    func selectedIndex_canBeUpdated() {
        let viewModel = PilgrimageMapViewModel(pilgrimages: dummyPilgrimageList)
        viewModel.selectedIndex = 3
        #expect(viewModel.selectedIndex == 3)
    }
}
