//
//  NaiveGeoJSONParser.swift
//  WaadsuMap
//
//  Created by Zhansaya Ayazbayeva on 2021-07-18.
//

import Foundation

// Упрощенный парсер GeoJSON.
// Принимает на вход сериализованный FeatureCollection,
// поле geometry внутри отдельных Feature принимают только MultiPolygon.
class NaiveGeoJSONParser {
    
    typealias JSONDictionary = [String : Any]

    // может бросить GeoJSONLoaderError.parseError если формат не соответствует поддерживаемому
    func parse(_ data: JSONDictionary) throws -> NaiveGeoJSON {
        guard let featuresJSON = data["features"] as? [JSONDictionary] else {
            throw GeoJSONLoaderError.parseError
        }
        return NaiveGeoJSON(faetures: try parseFeatures(featuresJSON))
    }
    
    private func parseFeatures(_ data: [JSONDictionary]) throws -> [NaiveFeature] {
        var features: [NaiveFeature] = []
        for elem in data {
            features.append(try parseFeature(elem))
        }
        return features
    }
    
    private func parseFeature(_ data: JSONDictionary) throws -> NaiveFeature {
        guard let geometryJSON = data["geometry"] as? JSONDictionary else {
            throw GeoJSONLoaderError.parseError
        }
        return NaiveFeature(geometry: try parseMultiPolygonGeometry(geometryJSON))
    }
    
    private func parseMultiPolygonGeometry(_ data: JSONDictionary) throws -> MultiPolygonGeometry {
        guard let coordinatesArray = data["coordinates"] as? [[[[Double]]]] else {
            throw GeoJSONLoaderError.parseError
        }
        
        var polygons: [PolygonGeometry] = []
        
        for topElem in coordinatesArray {
            var points: [GeoPoint] = []
            // Этот массив содержит один элемент - подмассив координат
            for polygonCoordinates in topElem.flatMap({ $0 }) {
                guard let point = GeoPoint.fromArray(arr: polygonCoordinates) else {
                    throw GeoJSONLoaderError.parseError
                }
                points.append(point)
            }
            let polygonGeometry = PolygonGeometry(points: points)
            polygons.append(polygonGeometry)
        }
        return MultiPolygonGeometry(polygons: polygons)
    }
}
