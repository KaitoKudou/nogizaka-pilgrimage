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
        case .aboutDeveloper: return String(localized: .menuAboutDeveloper)
        case .contact: return String(localized: .menuContact)
        case .termsOfUse: return String(localized: .menuTerms)
        case .openSourceLicense: return String(localized: .menuOpenSourceLicense)
        case .iconLicense: return String(localized: .menuIconLicense)
        case .privacyPolicy: return String(localized: .menuPrivacyPolicy)
        case .appVersion(let version): return String(format: String(localized: .menuAppVersion), version)
        }
    }
}

@MainActor
@Observable
final class MenuViewModel {
    enum Action {
        case navigate(MenuDestination)
        case openURL(URL)
    }

    @ObservationIgnored
    @Dependency(BuildClient.self) private var buildClient

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
