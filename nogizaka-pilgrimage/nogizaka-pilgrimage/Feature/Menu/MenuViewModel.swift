//
//  MenuViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/19.
//

import Dependencies
import Foundation

enum MenuDestination: Hashable {
    case openSourceLicense
    case iconLicense
}

enum MenuItem: Hashable {
    case aboutDeveloper
    case contact
    case termsOfUse
    case openSourceLicense
    case iconLicense
    case privacyPolicy
    case appVersion(String)

    var title: String {
        switch self {
        case .aboutDeveloper: return R.string.localizable.menu_about_developer()
        case .contact: return R.string.localizable.menu_contact()
        case .termsOfUse: return R.string.localizable.menu_terms()
        case .openSourceLicense: return R.string.localizable.menu_open_source_license()
        case .iconLicense: return R.string.localizable.menu_icon_license()
        case .privacyPolicy: return R.string.localizable.menu_privacy_policy()
        case .appVersion(let version): return R.string.localizable.menu_app_version(version)
        }
    }
}

@Observable
final class MenuViewModel {
    enum Action {
        case navigate(MenuDestination)
        case openURL(URL)
    }

    @ObservationIgnored
    @Dependency(\.buildClient) private var buildClient

    var appVersion: String {
        buildClient.appVersion()
    }

    func action(for item: MenuItem) -> Action? {
        switch item {
        case .aboutDeveloper:
            return .openURL(URL(string: "https://twitter.com/kudokai00")!)
        case .contact:
            return .openURL(URL(string: "https://forms.gle/dVsUCgo6GkoLUqxA7")!)
        case .termsOfUse:
            return .openURL(URL(string: "https://sites.google.com/view/nogi-jyunrei/terms")!)
        case .openSourceLicense:
            return .navigate(.openSourceLicense)
        case .iconLicense:
            return .navigate(.iconLicense)
        case .privacyPolicy:
            return .openURL(URL(string: "https://sites.google.com/view/nogi-jyunrei/privacy-policy")!)
        case .appVersion:
            return nil
        }
    }
}
