//
//  NativeAdvanceView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/04/19.
//

import SwiftUI
import GoogleMobileAds

struct NativeAdvanceView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let nativeAdvanceViewController = NativeAdvanceViewController()
        return nativeAdvanceViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
