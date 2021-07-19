//
//  NaiveGeoJSON.swift
//  WaadsuMap
//
//  Created by Zhansaya Ayazbayeva on 2021-07-18.
//

import Foundation

// Поддерживает ответ с частного запроса с https://waadsu.com/api/russia.geo.json
struct NaiveGeoJSON {
    let faetures: [NaiveFeature]
}

// Поддерживает только MultiPolygonGeometry
struct NaiveFeature {
    let geometry: MultiPolygonGeometry
}

struct MultiPolygonGeometry {
    let polygons: [PolygonGeometry]
}

struct PolygonGeometry {
    let points: [GeoPoint]
}

struct GeoPoint {
    let latitude: Double
    let longitude: Double
    
    // Принимает массив вида [longitude, latitude]
    static func fromArray(arr: [Double]) -> GeoPoint? {
        guard arr.count == 2 else {
            return nil
        }
        return GeoPoint(latitude: arr[1], longitude: arr[0])
    }
}



enum GeoJSONLoaderError: Error {
    case fetchError, noData, serializationError, invalidJSON, parseError
}
