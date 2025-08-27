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
    @Binding var centerCommand: CenterCommand?
    let initialRegion: MKCoordinateRegion
    let pilgrimages: [PilgrimageInformation]
    let showsUserLocation: Bool
    let onAnnotationSelected: (Int) -> Void
    
    struct CenterCommand: Identifiable, Equatable {
        static func == (lhs: CenterCommand, rhs: CenterCommand) -> Bool {
            return lhs.id == rhs.id
        }
        
        init(id: UUID = UUID(),
             target: CLLocationCoordinate2D,
             yOffset: CGFloat,
             animated: Bool
        ) {
            self.id = id
            self.target = target
            self.yOffset = yOffset
            self.animated = animated
        }
        
        var id = UUID()
        let target: CLLocationCoordinate2D
        let yOffset: CGFloat
        let animated: Bool
    }
    
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
        
        // 選択インデックスの変化に応じてスタイルを更新
        context.coordinator.applySelectionStyle(on: mapView, selectedIndex: selectedIndex)
        
        // 親から新しい指示が来ていたら「画面座標で」ずらしてセンタリング
        if let cmd = centerCommand, context.coordinator.lastCenterCommandID != cmd.id {
            context.coordinator.center(on: cmd.target, yOffset: cmd.yOffset, animated: cmd.animated)
            context.coordinator.lastCenterCommandID = cmd.id
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        weak var mapView: MKMapView?
        var lastCenterCommandID: UUID?
        var parent: ClusterMapView
        var lastAppliedRegion: MKCoordinateRegion?
        
        init(_ parent: ClusterMapView) {
            self.parent = parent
        }
        
        // 選択状態に応じてスタイル適用
        func applySelectionStyle(on mapView: MKMapView, selectedIndex: Int) {
            for ann in mapView.annotations {
                guard let pa = ann as? PilgrimageAnnotation,
                      let v = mapView.view(for: pa) else { continue }
                if pa.index == selectedIndex {
                    v.image = UIImage(named: R.image.map_pin.name)
                } else {
                    v.image = UIImage(named: R.image.unselected_map_pin.name)
                }
            }
        }
        
        // 画面座標でオフセット → 地理座標へ変換してカメラを維持したまま移動
        func center(on target: CLLocationCoordinate2D, yOffset: CGFloat, animated: Bool) {
            guard let mapView else { return }
            let pt = mapView.convert(target, toPointTo: mapView)
            let shifted = CGPoint(x: pt.x, y: pt.y + yOffset)
            let newCenter = mapView.convert(shifted, toCoordinateFrom: mapView)
            
            let cam = mapView.camera
            let newCam = MKMapCamera(
                lookingAtCenter: newCenter,
                fromDistance: cam.centerCoordinateDistance, // ズーム維持
                pitch: cam.pitch,                           // ピッチ維持
                heading: cam.heading                        // 回転維持
            )
            mapView.setCamera(newCam, animated: animated)
        }
        
        // クラスタアノテーションビューの設定
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // ユーザー位置のアノテーションはスキップ
            if annotation is MKUserLocation {
                return nil
            }
            
            // クラスターアノテーション
            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = "cluster"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                    annotationView?.displayPriority = .defaultHigh
                } else {
                    annotationView?.annotation = cluster
                }
                
                // クラスター内のアノテーション数を表示
                annotationView?.markerTintColor = .systemPurple
                annotationView?.glyphText = "\(cluster.memberAnnotations.count)"
                return annotationView
            }
            
            // 通常のピンアノテーション
            if let pilgrimageAnnotation = annotation as? PilgrimageAnnotation {
                let identifier = "pilgrimage"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: pilgrimageAnnotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = false
                } else {
                    annotationView?.annotation = pilgrimageAnnotation
                }
                
                // カスタムピン画像を設定
                annotationView?.image = (pilgrimageAnnotation.index == parent.selectedIndex) ? UIImage(named: R.image.map_pin.name) : UIImage(named: R.image.unselected_map_pin.name)
                annotationView?.clusteringIdentifier = "pilgrimageCluster" // これによりクラスタリングが有効になる
                
                return annotationView
            }
            
            return nil
        }
        
        // アノテーションがタップされたときの処理
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let pilgrimageAnnotation = view.annotation as? PilgrimageAnnotation {
                // SwiftUI側の選択変更を促す
                parent.onAnnotationSelected(pilgrimageAnnotation.index)
                // 直ちに色反映
                applySelectionStyle(on: mapView, selectedIndex: pilgrimageAnnotation.index)
            }
            
            // クラスターがタップされた場合は拡大して表示
            if let cluster = view.annotation as? MKClusterAnnotation {
                // 座標が有効であることを確認
                if CLLocationCoordinate2DIsValid(cluster.coordinate) {
                    let currentSpan = mapView.region.span
                    let newSpan = MKCoordinateSpan(
                        latitudeDelta: currentSpan.latitudeDelta * 0.5,
                        longitudeDelta: currentSpan.longitudeDelta * 0.5
                    )
                    
                    let region = MKCoordinateRegion(
                        center: cluster.coordinate,
                        span: newSpan
                    )
                    
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}
