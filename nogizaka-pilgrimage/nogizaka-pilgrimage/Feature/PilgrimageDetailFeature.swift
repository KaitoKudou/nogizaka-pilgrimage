//
//  PilgrimageDetailFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import ComposableArchitecture

struct PilgrimageDetailFeature: Reducer {
    struct State: Equatable {
        static func == (lhs: State, rhs: State) -> Bool {
            return lhs.favoriteState == rhs.favoriteState &&
            lhs.checkInState == rhs.checkInState &&
            lhs.alert == rhs.alert &&
            lhs.confirmationDialog == rhs.confirmationDialog
        }

        var favoriteState: FavoriteFeature.State
        var checkInState: CheckInFeature.State
        @PresentationState var alert: AlertState<Action>?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    enum Action: Equatable {
        static func == (lhs: PilgrimageDetailFeature.Action, rhs: PilgrimageDetailFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (.favoriteAction, .favoriteAction):
                return true
            case (.checkInAction , .checkInAction):
                return true
            case (.showNotNearbyAlert, .showNotNearbyAlert):
                return true
            case (.alertDismissed, .alertDismissed):
                return true
            case (.routeButtonTapped, .routeButtonTapped):
                return true
            case (.confirmationDialog, .confirmationDialog):
                return true
            default: return false
            }
        }
        
        case favoriteAction(FavoriteFeature.Action)
        case checkInAction(CheckInFeature.Action)
        case showNotNearbyAlert
        case alertDismissed(PresentationAction<Action>)
        case routeButtonTapped(latitude: String, longitude: String)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        @CasePathable
        enum ConfirmationDialog: Equatable {
            case appleMapButtonTapped(latitude: String, longitude: String)
            case googleMapsButtonTapped(latitude: String, longitude: String)
        }
    }

    @Dependency(\.routeActionClient) var routeActionClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .favoriteAction(let action):
                return FavoriteFeature().reduce(into: &state.favoriteState, action: action)
                    .map { Action.favoriteAction($0) }
            case .checkInAction(let action):
                return CheckInFeature().reduce(into: &state.checkInState, action: action)
                    .map { Action.checkInAction($0) }
            case .showNotNearbyAlert:
                state.alert = .init(
                    title: .init(R.string.localizable.alert_not_nearby())
                )
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .routeButtonTapped(let latitude, let longitude):
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState(R.string.localizable.confirmation_dialog_cancel())
                    }
                    ButtonState(action: .appleMapButtonTapped(latitude: latitude, longitude: longitude)) {
                        TextState(R.string.localizable.confirmation_dialog_apple_map())
                    }
                    ButtonState(action: .googleMapsButtonTapped(latitude: latitude, longitude: longitude)) {
                        TextState(R.string.localizable.confirmation_dialog_google_maps())
                    }
                }
                return .none
            case .confirmationDialog(.presented(.appleMapButtonTapped(let latitude, let longitude))):
                return .run { _ in
                    await routeActionClient.viewOnMap(latitude, longitude)
                }
            case .confirmationDialog(.presented(.googleMapsButtonTapped(let latitude, let longitude))):
                return .run { _ in
                    await routeActionClient.viewOnGoogleMaps(latitude, longitude)
                }
            case .confirmationDialog(.dismiss):
                state.confirmationDialog = nil
                return .none
            }
        }
    }
}
