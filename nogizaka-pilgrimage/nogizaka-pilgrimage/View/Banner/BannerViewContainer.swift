//
//  BannerViewContainer.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2025/03/27.
//

import GoogleMobileAds
import SwiftUI

enum AdUnitID {
    case menu
    case pilgrimageDetail
    case checkIn

    var id: String {
        switch self {
        case .menu:
            return "ca-app-pub-4288570549847775/4522473368"
        case .pilgrimageDetail:
            return "ca-app-pub-4288570549847775/3400963383"
        case .checkIn:
            return "ca-app-pub-4288570549847775/7654320580"
        }
    }
}

struct BannerViewContainer: UIViewControllerRepresentable {
    private let bannerView = BannerView()
    let adUnitID: AdUnitID

    init(adUnitID: AdUnitID) {
        self.adUnitID = adUnitID
    }

    func makeUIViewController(context: Context) -> some BannerViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID.id
        bannerView.rootViewController = bannerViewController
        bannerView.delegate = context.coordinator
        bannerViewController.view.addSubview(bannerView)
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    static func getAdSize(width: CGFloat) -> AdSize {
        return currentOrientationAnchoredAdaptiveBanner(width: width)
    }

    class Coordinator: NSObject, BannerViewControllerWidthDelegate, BannerViewDelegate {
        let parent: BannerViewContainer

        init(_ parent: BannerViewContainer) {
            self.parent = parent
        }

        // MARK: - BannerViewControllerWidthDelegate methods
        func bannerViewController(_: BannerViewController, didUpdate width: CGFloat) {
            guard width > 0 else { return }
            
            let request = Request()
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                request.scene = windowScene
                
                parent.bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
                parent.bannerView.load(request)
                
            }
        }

        // MARK: - GADBannerViewDelegate methods
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner failed to receive ad with error: \(error.localizedDescription)")
        }
    }
}
