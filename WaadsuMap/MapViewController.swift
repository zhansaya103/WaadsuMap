//
//  ViewController.swift
//  WaadsuMap
//
//  Created by Zhansaya Ayazbayeva on 2021-07-18.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class MapViewController: UIViewController {
    
    private let geoJSONLoader = GeoJSONLoader(geoJSONParser: NaiveGeoJSONParser())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Точка где-то в центре России
        let camera = GMSCameraPosition.camera(withLatitude: 63, longitude: 95, zoom: 3.0)
        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        loadRussiaBordersAsync(mapView)
        view.addSubview(mapView)
    }
    
    func loadRussiaBordersAsync(_ mapView: GMSMapView) {
        geoJSONLoader.load(url: URL(string: "https://waadsu.com/api/russia.geo.json")!, then: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let geoJSON):
                    for feature in geoJSON.faetures {
                        var longestPolygonLengthInMeters: Double = 0
                        var longestPolygonMarker: GMSMarker?
                        var borderTotalLengthInMeters: Double = 0
                        // каждый полигон является замкнутой территорией (включая анклавы, острова)
                        for polygon in feature.geometry.polygons {
                            let path = GMSMutablePath()
                            for point in polygon.points {
                                path.add(point.toCLLocationCoordinate2D())
                            }
                            // GMSPolyline отрисовывает маршрут (path) в виде линии
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 3
                            polyline.geodesic = true
                            polyline.map = mapView

                            let borderLengthInMeters = path.length(of: GMSLengthKind.geodesic)
                            borderTotalLengthInMeters += Double(borderLengthInMeters)
                            
                            // добавляем маркер у первой точки маршрута для отображения длины
                            let lengthInfoMarker = GMSMarker(position: polygon.points[0].toCLLocationCoordinate2D())
                            lengthInfoMarker.title = String(format: "Длина маршрута: %.2f км", borderLengthInMeters.fromMetersToKilometers())
                            lengthInfoMarker.map = mapView
                            
                            if borderLengthInMeters >= longestPolygonLengthInMeters {
                                longestPolygonLengthInMeters = borderLengthInMeters
                                longestPolygonMarker = lengthInfoMarker
                            }
                        }

                        let flagImage = UIImage(named: "RussianFlag")!.withRenderingMode(.alwaysOriginal)
                        let markerView = UIImageView(image: flagImage)
                        markerView.tintColor = .clear
                        
                        let totalLengthInfoMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 63, longitude: 95))
                        totalLengthInfoMarker.iconView = markerView
                        totalLengthInfoMarker.tracksViewChanges = true
                        totalLengthInfoMarker.title = String(format: "Суммарная длина: %.2f км", borderTotalLengthInMeters.fromMetersToKilometers())
                        totalLengthInfoMarker.map = mapView
                        
                        // Протяженность границы 62134.18 км
                        if let longestPolygonMarker = longestPolygonMarker {
                            let bigFlagImage = UIImage(named: "RussianFlagBig")!.withRenderingMode(.alwaysOriginal)
                            let bigFlagView = UIImageView(image: bigFlagImage)
                            bigFlagView.tintColor = .clear
                            longestPolygonMarker.iconView = bigFlagView
                        }
                    }
                case .failure(let err):
                    print(err)
                }
            }
        })
    }
}


extension GeoPoint {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension Double {
    func fromMetersToKilometers() -> Double {
        return self / 1000.0
    }
}
