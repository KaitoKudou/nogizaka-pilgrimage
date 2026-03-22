//
//  ClusterMapView.swift
//  nogizaka-pilgrimage
//
//  Created on 2025/08/06.
//

import SwiftUI
import MapKit

struct ClusterMapView: UIViewRepresentable {
    @Binding var selectedIndex: Int
    @Binding var centerCommand: MapCameraCommand?
    let initialRegion: MKCoordinateRegion
    let initialYOffset: CGFloat
    let mapWidth: CGFloat
    let pilgrimages: [PilgrimageEntity]
    let showsUserLocation: Bool
    let onAnnotationSelected: (Int) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = initialRegion
        mapView.showsUserLocation = showsUserLocation
        context.coordinator.mapView = mapView
        
        let annotations = pilgrimages.enumerated().map { index, pilgrimage in
            PilgrimageAnnotation(pilgrimage: pilgrimage, index: index)
        }
        mapView.addAnnotations(annotations)
        
        // 初期の選択色を反映
        context.coordinator.applySelectionStyle(on: mapView, selectedIndex: selectedIndex)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.mapView = mapView

        // 初回のみ: 縦長画面では横幅がズーム基準なので、横幅基準でオフセットを計算
        if !context.coordinator.didApplyInitialOffset && mapWidth > 0 && initialYOffset > 0 {
            context.coordinator.didApplyInitialOffset = true
            // Phase 1: 地理的近似で即座にほぼ正しい位置を表示
            let latitudeShift = (initialYOffset / mapWidth) * initialRegion.span.latitudeDelta
            let adjustedCenter = CLLocationCoordinate2D(
                latitude: initialRegion.center.latitude - latitudeShift,
                longitude: initialRegion.center.longitude
            )
            mapView.region = MKCoordinateRegion(center: adjustedCenter, span: initialRegion.span)

            // Phase 2: リージョン適用後にピンタップと同じ center メソッドで正確な位置に補正
            let region = initialRegion
            let yOffset = initialYOffset
            Task { @MainActor in
                context.coordinator.center(on: region.center, yOffset: yOffset, animated: false)
            }
        }

        // 選択インデックスの変化に応じてスタイルを更新
        context.coordinator.applySelectionStyle(on: mapView, selectedIndex: selectedIndex)

        // 親から新しい指示が来ていたら「画面座標で」ずらしてセンタリング
        if let cmd = centerCommand, context.coordinator.lastCameraCommandID != cmd.id {
            context.coordinator.center(on: cmd.target, yOffset: cmd.yOffset, animated: cmd.animated)
            context.coordinator.lastCameraCommandID = cmd.id
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
