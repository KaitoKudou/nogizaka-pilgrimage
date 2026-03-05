//
//  BannerViewControllerWidthDelegate.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/03/30.
//

import Foundation
import UIKit

// Delegate methods for receiving width update messages.
protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(
        _ bannerViewController: BannerViewController,
        didUpdate width: CGFloat
    )
}
