//
//  LocalizedStringResource+Keys.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/07.
//

import Foundation

extension LocalizedStringResource {
    // MARK: - TabView
    static let tabbarPilgrimage = LocalizedStringResource("tabbar_pilgrimage")
    static let tabbarCheckIn = LocalizedStringResource("tabbar_check_in")
    static let tabbarMenu = LocalizedStringResource("tabbar_menu")
    static let tabbarFavorite = LocalizedStringResource("tabbar_favorite")

    // MARK: - 聖地一覧
    static let navbarPilgrimageList = LocalizedStringResource("navbar_pilgrimage_list")
    static let pilgrimageListPlaceholder = LocalizedStringResource("pilgrimage_list_placeholder")

    // MARK: - ボタン
    static let commonBtnRouteSearchText = LocalizedStringResource("common_btn_route_search_text")
    static let commonBtnDetailText = LocalizedStringResource("common_btn_detail_text")

    // MARK: - 聖地詳細
    static let navbarPilgrimageDetail = LocalizedStringResource("navbar_pilgrimage_detail")
    static let checkInButton = LocalizedStringResource("check_in_button")
    static let checkInButtonAgain = LocalizedStringResource("check_in_button_again")

    // MARK: - お気に入り
    static let favoritesEmpty = LocalizedStringResource("favorites_empty")

    // MARK: - チェックイン
    static let checkedInEmpty = LocalizedStringResource("checked_in_empty")

    // MARK: - Alert
    static let alertLocation = LocalizedStringResource("alert_location")
    static let alertNotNearby = LocalizedStringResource("alert_not_nearby")
    static let alertFetchError = LocalizedStringResource("alert_fetch_error")
    static let alertUpdateError = LocalizedStringResource("alert_update_error")
    static let alertNetwork = LocalizedStringResource("alert_network")
    static let alertUnknown = LocalizedStringResource("alert_unknown")
    static let alertOptionalUpdate = LocalizedStringResource("alert_optional_update")
    static let alertForceUpdate = LocalizedStringResource("alert_force_update")
    static let alertOk = LocalizedStringResource("alert_ok")

    // MARK: - ConfirmationDialog
    static let confirmationDialogCancel = LocalizedStringResource("confirmation_dialog_cancel")
    static let confirmationDialogAppleMap = LocalizedStringResource("confirmation_dialog_apple_map")
    static let confirmationDialogGoogleMaps = LocalizedStringResource("confirmation_dialog_google_maps")

    // MARK: - メニュー
    static let menuAboutDeveloper = LocalizedStringResource("menu_about_developer")
    static let menuContact = LocalizedStringResource("menu_contact")
    static let menuTerms = LocalizedStringResource("menu_terms")
    static let menuOpenSourceLicense = LocalizedStringResource("menu_open_source_license")
    static let menuIconLicense = LocalizedStringResource("menu_icon_license")
    static let menuPrivacyPolicy = LocalizedStringResource("menu_privacy_policy")
    static let menuAppVersion = LocalizedStringResource("menu_app_version")
    static let menuSectionSupport = LocalizedStringResource("menu_section_support")
    static let menuSectionApp = LocalizedStringResource("menu_section_app")
    static let iconsBy = LocalizedStringResource("icons_by")
    static let icons8 = LocalizedStringResource("icons8")

    // MARK: - アカウント
    static let menuSectionAccount = LocalizedStringResource("menu_section_account")
    static let menuSignInWithApple = LocalizedStringResource("menu_sign_in_with_apple")
    static let menuSignOut = LocalizedStringResource("menu_sign_out")
    static let menuSignedInAs = LocalizedStringResource("menu_signed_in_as")
    static let alertSignOutConfirmation = LocalizedStringResource("alert_sign_out_confirmation")
    static let alertSignInError = LocalizedStringResource("alert_sign_in_error")
    static let alertSignOutError = LocalizedStringResource("alert_sign_out_error")
    static let menuSignedInFallback = LocalizedStringResource("menu_signed_in_fallback")

    // MARK: - サインイン促進
    static let signInPromotionLaunchMessage = LocalizedStringResource("sign_in_promotion_launch_message")
    static let signInPromotionLaunchDescription = LocalizedStringResource("sign_in_promotion_launch_description")
    static let signInPromotionCheckInMessage = LocalizedStringResource("sign_in_promotion_check_in_message")
    static let signInPromotionCheckInDescription = LocalizedStringResource("sign_in_promotion_check_in_description")
    static let signInPromotionSkip = LocalizedStringResource("sign_in_promotion_skip")

    // MARK: - チェックイン完了モーダル
    static let checkInCompletionFirstPilgrimage = LocalizedStringResource("check_in_completion_first_pilgrimage")
    static let checkInCompletionNthPilgrimage = LocalizedStringResource("check_in_completion_nth_pilgrimage")
    static let checkInCompletionCloudSaved = LocalizedStringResource("check_in_completion_cloud_saved")
    static let checkInCompletionLocalSaved = LocalizedStringResource("check_in_completion_local_saved")
    static let checkInCompletionMemoPlaceholder = LocalizedStringResource("check_in_completion_memo_placeholder")
    static let checkInCompletionClose = LocalizedStringResource("check_in_completion_close")
}
