//
//  CheckInFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import FirebaseFirestore
import ComposableArchitecture
import CoreLocation

@Reducer
struct CheckInFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var distance: Double = 0.0 // 現在地から聖地までの距離
        var hasCheckedIn: Bool = false // チェックインしているかどうか
        var checkedInPilgrimages: [PilgrimageInformation] = []
        var isLoading: Bool = false
        var hasError: Bool = false // 失敗アラートの表示を制御
        var errorMessage: String = ""
    }

    enum Action {
        case calculateDistance(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D)
        case addCheckedInList(pilgrimage: PilgrimageInformation)
        case fetchCheckedInList
        case verifyCheckedIn(pilgrimage: PilgrimageInformation)
        case startLoading
        case stopLoading
        case pilgrimageResponse(Result<[PilgrimageInformation]?, APIError>)
        case updateCheckedInStatus(Bool)
    }

    @Dependency(\.networkMonitor) var networkMonitor

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
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.updateCheckedInError)))
                    } catch {
                        await send(.pilgrimageResponse(.failure(.networkError)))
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
                    } catch let error as NSError where error.domain == FirestoreErrorDomain {
                        await send(.pilgrimageResponse(.failure(.fetchCheckedInError)))
                    } catch {
                        await send(.pilgrimageResponse(.failure(.networkError)))
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
