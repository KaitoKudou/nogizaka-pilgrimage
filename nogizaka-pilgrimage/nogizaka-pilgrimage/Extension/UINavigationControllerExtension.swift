//
//  UINavigationControllerExtension.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/20.
//

import UIKit

// NavigationBarの戻るボタンをModifier化した場合のスワイプで前画面に戻れなくなる事象を回避
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
