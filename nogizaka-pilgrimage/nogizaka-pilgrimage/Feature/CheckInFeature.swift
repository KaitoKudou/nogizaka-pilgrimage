//
//  CheckInFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import FirebaseFirestore
import ComposableArchitecture
import CoreLocation

struct CheckInFeature: Reducer {
    struct State: Equatable {
        var distance: Double = 0.0 // 現在地から聖地までの距離
        var hasCheckedIn: Bool = false // チェックインしているかどうか
        var checkedInPilgrimages: [PilgrimageInformation] = []
        var isLoading: Bool = false
        var hasError: Bool = false // 失敗アラートの表示を制御
        var errorMessage: String = ""
    }

    enum Action: Equatable {
        static func == (lhs: CheckInFeature.Action, rhs: CheckInFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.calculateDistance(lhsUser, lhsPilgrimage), .calculateDistance(rhsUser, rhsPilgrimage)):
                // CLLocationCoordinate2Dを比較する
                return lhsUser.latitude == rhsUser.latitude &&
                lhsUser.longitude == rhsUser.longitude &&
                lhsPilgrimage.latitude == rhsPilgrimage.latitude &&
                lhsPilgrimage.longitude == rhsPilgrimage.longitude
            case (.addCheckedInList, .addCheckedInList):
                return true
            case (.fetchCheckedInList, .fetchCheckedInList):
                return true
            case (.verifyCheckedIn(pilgrimage: _), .verifyCheckedIn(pilgrimage: _)):
                return true
            case (.startLoading, .startLoading):
                return true
            case (.stopLoading, .stopLoading):
                return true
            case (.pilgrimageResponse, .pilgrimageResponse):
                return true
            case (.updateCheckedInStatus, .updateCheckedInStatus):
                return true
            default:
                return false
            }
        }

        case calculateDistance(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D)
        case addCheckedInList(pilgrimage: PilgrimageInformation)
        case fetchCheckedInList
        case verifyCheckedIn(pilgrimage: PilgrimageInformation)
        case startLoading
        case stopLoading
        case pilgrimageResponse(Result<[PilgrimageInformation]?, APIError>)
        case updateCheckedInStatus(Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .calculateDistance(let userCoordinate, let pilgrimageCoordinate):
                let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)

                state.distance = userLocation.distance(from: pilgrimageLocation)
                return .none
            case .addCheckedInList(let pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("checked-in-list").document(uuid).collection("list")
                let documentReference = querySnapshot.document(pilgrimage.name)

                return .run { send in
                    await send(.stopLoading)
                    do {
                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            await send(.updateCheckedInStatus(false))
                        } else {
                            let data: [String: Any?] = [
                                "code": pilgrimage.code,
                                "name": pilgrimage.name,
                                "description": pilgrimage.description,
                                "latitude": pilgrimage.latitude,
                                "longitude": pilgrimage.longitude,
                                "address": pilgrimage.address,
                                "image_url": pilgrimage.imageURL?.absoluteString,
                                "copyright": pilgrimage.copyright,
                                "search_candidate_list": pilgrimage.searchCandidateList
                            ]
                            try await documentReference.setData(data as [String : Any])
                            await send(.pilgrimageResponse(.success(nil)))
                            await send(.updateCheckedInStatus(true))
                        }
                    } catch  {
                        await send(.pilgrimageResponse(.failure(.updateCheckedInError)))
                    }
                    await send(.stopLoading)
                }
            case .fetchCheckedInList:
                return .run { send in
                    await send(.startLoading)

                    do {
                        let uuid = await UIDevice.current.identifierForVendor!.uuidString
                        let querySnapshot = try await Firestore.firestore()
                            .collection("checked-in-list")
                            .document(uuid)
                            .collection("list")
                            .getDocuments()
                        var checkedInPilgrimages: [PilgrimageInformation] = []

                        for document in querySnapshot.documents {
                            let pilgrimage = try document.data(as: PilgrimageInformation.self)
                            checkedInPilgrimages.append(pilgrimage)
                        }
                        await send(.pilgrimageResponse(.success(checkedInPilgrimages)))
                    } catch {
                        await send(.pilgrimageResponse(.failure(.fetchCheckedInError)))
                    }

                    await send(.stopLoading)
                }
            case .verifyCheckedIn(let pilgrimage):
                let uuid = UIDevice.current.identifierForVendor!.uuidString
                let querySnapshot = Firestore.firestore().collection("checked-in-list").document(uuid).collection("list")

                return .run { send in
                    await send(.startLoading)
                    do {
                        if (try await querySnapshot.getDocuments().documents.first(where: { $0.documentID == pilgrimage.name })) != nil {
                            await send(.updateCheckedInStatus(true))
                        } else {
                            await send(.updateCheckedInStatus(false))
                        }
                    }
                    await send(.stopLoading)
                }
            case .startLoading:
                state.isLoading = true
                return .none
            case .stopLoading:
                state.isLoading = false
                return .none
            case .pilgrimageResponse(.success(let pilgrimages)):
                state.hasError = false
                if let pilgrimages = pilgrimages {
                    state.checkedInPilgrimages = pilgrimages
                }
                return .none
            case .pilgrimageResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                state.hasError = true
                return .none
            case .updateCheckedInStatus(let hasCheckedIn):
                state.hasCheckedIn = hasCheckedIn
                return .none
            }
        }
    }
}
