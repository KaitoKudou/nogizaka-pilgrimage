//
//  PilgrimageDetailFeature.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/02/12.
//

import ComposableArchitecture

struct PilgrimageDetailFeature: Reducer {
    struct State: Equatable {
        var favoriteState: FavoriteFeature.State
        var checkInState: CheckInFeature.State
        @PresentationState var alert: AlertState<Action>?
        @PresentationState var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }

    enum Action: Equatable {
        case favoriteAction(FavoriteFeature.Action)
        case checkInAction(CheckInFeature.Action)
        case showNotNearbyAlert
        case alertDismissed(PresentationAction<Action>)
        case routeButtonTapped
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        @CasePathable
        enum ConfirmationDialog {
            case appleMapButtonTapped
            case googleMapsButtonTapped
        }
    }

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
            case .routeButtonTapped:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState(R.string.localizable.confirmation_dialog_cancel())
                    }
                    ButtonState(action: .appleMapButtonTapped) {
                        TextState(R.string.localizable.confirmation_dialog_apple_map())
                    }
                    ButtonState(action: .googleMapsButtonTapped) {
                        TextState(R.string.localizable.confirmation_dialog_google_maps())
                    }
                }
                return .none
            case .confirmationDialog(.presented(.appleMapButtonTapped)):
                // TODO: Apple Mapを開く
                print("Apple Mapを開く")
                return .none
            case .confirmationDialog(.presented(.googleMapsButtonTapped)):
                // TODO: Google Mapsを開く
                print("Google Mapsを開く")
                return .none
            case .confirmationDialog:
                return .none
            }
        }
    }
}
