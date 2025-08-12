//
//  ClusterMapView.swift
//  nogizaka-pilgrimage
//
//  Created on 2025/08/06.
//

import SwiftUI
import MapKit

struct ClusterMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let pilgrimages: [PilgrimageInformation]
    let showsUserLocation: Bool
    let onAnnotationSelected: (Int) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = showsUserLocation
        
        let annotations = pilgrimages.enumerated().map { index, pilgrimage in
            PilgrimageAnnotation(pilgrimage: pilgrimage, index: index)
        }
        mapView.addAnnotations(annotations)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusterMapView
        
        init(_ parent: ClusterMapView) {
            self.parent = parent
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
                    // calloutは使用しないので、falseに設定
                    annotationView?.canShowCallout = false
                } else {
                    annotationView?.annotation = pilgrimageAnnotation
                }
                
                // カスタムピン画像を設定
                annotationView?.image = R.image.map_pin()
                annotationView?.clusteringIdentifier = "pilgrimageCluster" // これによりクラスタリングが有効になる
                
                return annotationView
            }
            
            return nil
        }
        
        // アノテーションがタップされたときの処理
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let pilgrimageAnnotation = view.annotation as? PilgrimageAnnotation {
                // インデックスを更新するだけにし、マップの移動はPilgrimageMapViewのonChange内で行う
                parent.onAnnotationSelected(pilgrimageAnnotation.index)
            }
            
            // クラスターがタップされた場合は拡大して表示
            if let cluster = view.annotation as? MKClusterAnnotation {
                // 座標が有効であることを確認
                if CLLocationCoordinate2DIsValid(cluster.coordinate) {
                    let newSpan = MKCoordinateSpan(
                        latitudeDelta: parent.region.span.latitudeDelta * 0.5,
                        longitudeDelta: parent.region.span.longitudeDelta * 0.5
                    )
                    
                    let region = MKCoordinateRegion(
                        center: cluster.coordinate,
                        span: newSpan
                    )
                    
                    mapView.setRegion(region, animated: true)
                }
            }
        }
        
        // regionが変更されたときに親のリージョンを更新
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            Task { @MainActor in
                parent.region = mapView.region
            }
        }
    }
}
