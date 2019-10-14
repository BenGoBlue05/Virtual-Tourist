//
//  VTClient.swift
//  Virtual Tourist
//
//  Created by Ben Lewis on 10/14/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation
import UIKit
class VTClient {
    
    static let shared = VTClient()
    
    func photosRequest(_ lat: Double, _ lon: Double, page: Int = 1, perPage: Int = 15) -> String {
        let baseApi = "https://www.flickr.com/services/rest/"
        let method = "method=flickr.photos.search&api_key="
        return "\(baseApi)?\(method)&format=json&api_key=\(Secrets.apiKey)&lat=\(lat)&lon=\(lon)&page=\(page)&per_page=\(perPage)"
    }
    
    func getPhotos(_ lat: Double, _ lon: Double, page: Int = 1, perPage: Int = 15, completion: @escaping (VTResult<VTPhotos>) -> Void) {
        let baseApi = "https://www.flickr.com/services/rest/"
        let method = "method=flickr.photos.search"
        let urlStr = "\(baseApi)?\(method)&format=json&api_key=\(Secrets.apiKey.rawValue)&lat=\(lat)&lon=\(lon)&page=\(page)&per_page=\(perPage)"
        let task = URLSession.shared.dataTask(with: URL(string: urlStr)!) { data, response, error in
            let genericError = "An error occurred"
            var result: VTResult<VTPhotos>!
            if let data = data {
                let subdata = data.subdata(in: 14..<data.count - 1)
                let decoder = JSONDecoder()
                if let photosResponse = try? decoder.decode(PhotosResponse.self, from: subdata) {
                    result = VTResult.success(photosResponse.photos)
                } else {
                    let errorResponse = try? decoder.decode(VTErrorResponse.self, from: subdata)
                    result = VTResult.error(errorResponse?.message ?? genericError)
                }
            } else {
                result = VTResult.error(genericError)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
    }

}
