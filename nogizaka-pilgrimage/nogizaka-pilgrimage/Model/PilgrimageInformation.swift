//
//  PilgrimageInformation.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/18.
//

import CoreLocation
import Foundation

struct PilgrimageInformation: Hashable, Decodable {
    let code: String
    let name: String
    let description: String
    let latitude: String
    let longitude: String
    let address: String
    let imageURL: URL?
    let copyright: String?
    let searchCandidateList: [String]

    /// 位置座標
    var coordinate: CLLocationCoordinate2D {
        // 注意）緯度、経度は必須項目のため、強制アンラップを使ってよいとする
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
    }

    init(code: String, name: String, description: String,
         latitude: String,longitude: String, address: String,
         imageURL: URL?, copyright: String?, searchCandidateList: [String]) {
        self.code = code
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.imageURL = imageURL
        self.copyright = copyright
        self.searchCandidateList = searchCandidateList
    }

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case description
        case latitude
        case longitude
        case address
        case imageURL
        case copyright
        case searchCandidateList = "search_candidate_list"
    }
}

extension PilgrimageInformation: Identifiable {
    var id: String {
        return code
    }
}

// MARK: - dummy
let dummyPilgrimageList: [PilgrimageInformation] = [
    PilgrimageInformation(
        code: "001",
        name: "乃木坂駅",
        description: "1stアルバム「透明な色」のジャケット写真の撮影場所です。発車音は「君の名は希望」です。",
        latitude: "35.666827",
        longitude: "139.726497",
        address: "東京都港区南青山１丁目２５−８",
        imageURL: nil,
        copyright: "@2023 Google, 画像提供：たく",
        searchCandidateList: ["乃木坂駅", "のぎざかえき", "ノギザカエキ", "nogizakaeki"]
    ),
    PilgrimageInformation(
        code: "002",
        name: "乃木神社",
        description: "乃木坂46メンバーの成人式などで使われ、メンバー直筆の絵馬なども展示されています。",
        latitude: "35.668825",
        longitude: "139.727961",
        address: "東京都港区赤坂８丁目１１−２７",
        imageURL: nil,
        copyright: "@2023 Google, 画像提供：ゆるバップ", 
        searchCandidateList: ["乃木神社", "のぎじんじゃ", "ノギジンジャ", "nogijinjya"]
    ),
    PilgrimageInformation(
        code: "003",
        name: "渋谷駅",
        description: "渋谷駅の銀座線ホームは31stシングル「ここにはないもの」のMVで使用されました。",
        latitude: "35.658034",
        longitude: "139.701636",
        address: "東京都渋谷区渋谷２丁目",
        imageURL: nil,
        copyright: "@2023 Google, 画像提供：cana kei",
        searchCandidateList: ["渋谷駅", "しぶやえき", "シブヤエキ", "sibuyaeki"]
    ),
    PilgrimageInformation(
        code: "004",
        name: "スペイン坂",
        description: "渋谷にあるスペイン坂は26thシングル「僕は僕を好きになる」の山下美月さんが与田祐希さん、齋藤飛鳥さんと合流するシーンで使われました。",
        latitude: "35.661511",
        longitude: "139.698851",
        address: "東京都渋谷区宇田川町１６−１５",
        imageURL: nil,
        copyright: "@2023 Google, 画像提供：I Ar",
        searchCandidateList: ["スペイン坂", "すぺいんざか", "スペインザカ", "supeinzaka"]
    ),
    PilgrimageInformation(
        code: "005",
        name: "秋葉原UDX",
        description: "秋葉原UDX横の線路沿いの広場は賀喜遥香さんがセンターを務める4期生曲「I see…」で4期生が電車と並走するように走るシーンで使われました。",
        latitude: "35.700494",
        longitude: "139.772645",
        address: "東京都千代田区外神田４丁目１４−１",
        imageURL: nil,
        copyright: nil,
        searchCandidateList: ["秋葉原UDX", "あきはばら", "アキハバラ", "akihabara"]
    ),
]
