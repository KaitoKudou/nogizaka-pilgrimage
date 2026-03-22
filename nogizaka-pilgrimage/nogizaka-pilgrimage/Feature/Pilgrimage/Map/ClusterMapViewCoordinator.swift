//
//  ClusterMapViewCoordinator.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/22.
//

import MapKit

extension ClusterMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        weak var mapView: MKMapView?
        var lastCameraCommandID: UUID?
        var parent: ClusterMapView
        var didApplyInitialOffset = false

        init(_ parent: ClusterMapView) {
            self.parent = parent
        }

        // MARK: - カメラ操作

        /// 画面座標でオフセット → 地理座標へ変換してカメラを維持したまま移動
        func center(on target: CLLocationCoordinate2D, yOffset: CGFloat, animated: Bool) {
            guard let mapView else { return }
            let pt = mapView.convert(target, toPointTo: mapView)
            let shifted = CGPoint(x: pt.x, y: pt.y + yOffset)
            let newCenter = mapView.convert(shifted, toCoordinateFrom: mapView)

            let cam = mapView.camera
            let newCam = MKMapCamera(
                lookingAtCenter: newCenter,
                fromDistance: cam.centerCoordinateDistance,
                pitch: cam.pitch,
                heading: cam.heading
            )
            mapView.setCamera(newCam, animated: animated)
        }

        // MARK: - 選択スタイル

        /// 選択状態に応じてピン画像を切り替える
        func applySelectionStyle(on mapView: MKMapView, selectedIndex: Int) {
            for ann in mapView.annotations {
                guard let pa = ann as? PilgrimageAnnotation,
                      let v = mapView.view(for: pa) else { continue }
                if pa.index == selectedIndex {
                    v.image = UIImage(resource: .mapPin)
                } else {
                    v.image = UIImage(resource: .unselectedMapPin)
                }
            }
        }

        // MARK: - MKMapViewDelegate

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            if let cluster = annotation as? MKClusterAnnotation {
                let identifier = "cluster"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                    annotationView?.displayPriority = .defaultHigh
                } else {
                    annotationView?.annotation = cluster
                }

                annotationView?.markerTintColor = .systemPurple
                annotationView?.glyphText = "\(cluster.memberAnnotations.count)"
                return annotationView
            }

            if let pilgrimageAnnotation = annotation as? PilgrimageAnnotation {
                let identifier = "pilgrimage"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

                if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: pilgrimageAnnotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = false
                } else {
                    annotationView?.annotation = pilgrimageAnnotation
                }

                annotationView?.image = (pilgrimageAnnotation.index == parent.selectedIndex) ? UIImage(resource: .mapPin) : UIImage(resource: .unselectedMapPin)
                annotationView?.clusteringIdentifier = "pilgrimageCluster"

                return annotationView
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let pilgrimageAnnotation = view.annotation as? PilgrimageAnnotation {
                parent.onAnnotationSelected(pilgrimageAnnotation.index)
                applySelectionStyle(on: mapView, selectedIndex: pilgrimageAnnotation.index)
            }

            if let cluster = view.annotation as? MKClusterAnnotation {
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
