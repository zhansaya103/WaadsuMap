//
//  GeoJSONLoader.swift
//  WaadsuMap
//
//  Created by Zhansaya Ayazbayeva on 2021-07-18.
//

import Foundation
import GoogleMapsUtils

class GeoJSONLoader {
    private let geoJSONParser: NaiveGeoJSONParser
    
    init(geoJSONParser: NaiveGeoJSONParser) {
        self.geoJSONParser = geoJSONParser
    }
    
    func load(url: URL, then onComplete: @escaping (Result<NaiveGeoJSON, GeoJSONLoaderError>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                onComplete(.failure(.fetchError))
                return
            }
            guard let urlContent = data else {
                onComplete(.failure(.noData))
                return
            }
            do {
                guard let jsonMap = try JSONSerialization.jsonObject(with:urlContent) as? [String : Any] else {
                    onComplete(.failure(.invalidJSON))
                    return
                }
                if !JSONSerialization.isValidJSONObject(jsonMap) {
                    onComplete(.failure(.invalidJSON))
                    return
                }
                let geoJSON = try self.geoJSONParser.parse(jsonMap)
                onComplete(.success(geoJSON))
                return
            } catch {
                if let geoJSONLoadError = error as? GeoJSONLoaderError {
                    onComplete(.failure(geoJSONLoadError))
                } else {
                    onComplete(.failure(.serializationError))
                }
            }
        }
        task.resume()
    }
    
}
