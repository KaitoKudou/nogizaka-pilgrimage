//
//  BannerView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/30.
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

struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
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

        // 初期表示時に広告ビューのサイズを設定
        DispatchQueue.main.async {
            bannerView.frame = CGRect(origin: .zero, size: CGSize(width: viewWidth, height: 60))
            bannerViewController.view.setNeedsLayout()
        }

        return bannerViewController
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {
        guard viewWidth != .zero else { return }

        // Request a banner ad with the updated viewWidth.
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    static func getAdSize(width: CGFloat) -> GADAdSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
    }

    class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate {
        let parent: BannerView

        init(_ parent: BannerView) {
            self.parent = parent
        }

        // MARK: - BannerViewControllerWidthDelegate methods
        func bannerViewController(_: BannerViewController, didUpdate width: CGFloat) {
            // Pass the viewWidth from Coordinator to BannerView.
            parent.viewWidth = width
            parent.bannerView.load(GADRequest())
        }

        // MARK: - GADBannerViewDelegate methods
        func bannerView(_: GADBannerView, didFailToReceiveAdWithError error: Error) {
            // エラー時にも広告ビューのサイズを設定し直す
            DispatchQueue.main.async {
                self.parent.bannerView.frame = CGRect(origin: .zero, size: CGSize(width: self.parent.viewWidth, height: 60))
                self.parent.bannerView.rootViewController?.view.setNeedsLayout()
            }
        }
    }
}
