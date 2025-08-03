//
//  NativeAdvanceViewController.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/18.
//

import GoogleMobileAds

final class NativeAdvanceViewController: UIViewController {
    private var heightConstraint: NSLayoutConstraint?
    private var nativeAdView: NativeAdView!
    private var adLoader: AdLoader!
    private let adUnitID = "ca-app-pub-4288570549847775/6418050522"

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let nibObjects = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? NativeAdView
        else {
            return assert(false, "Could not load nib file for adView")
        }
        setAdView(adView)
        refreshAd()
    }

    func setAdView(_ view: NativeAdView) {
        nativeAdView = view
        nativeAdView.backgroundColor = .white

        // 影を追加するためのCALayerを作成
        nativeAdView.layer.masksToBounds = false
        nativeAdView.layer.shadowColor = UIColor.gray.cgColor
        nativeAdView.layer.shadowOpacity = 0.8
        nativeAdView.layer.shadowRadius = 4
        nativeAdView.layer.shadowOffset = CGSize(width: 0, height: 4)

        self.view.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false

        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }

    func refreshAd() {
        let multipleAdOptions = MultipleAdsAdLoaderOptions()
        multipleAdOptions.numberOfAds = 1;

        adLoader = AdLoader(
            adUnitID: adUnitID, 
            rootViewController: self,
            adTypes: [.native],
            options: [multipleAdOptions]
        )
        adLoader.delegate = self

        let request = Request()
        // iPadでのAdMob広告表示エラーに対応
        // See also https://qiita.com/SNQ-2001/items/1f19c3b6ce584ef25d6f
        request.scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        adLoader.load(request)
    }
}

extension NativeAdvanceViewController: NativeAdDelegate, NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self

        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        nativeAdView.callToActionView?.isUserInteractionEnabled = false

        nativeAdView.nativeAd = nativeAd
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}
