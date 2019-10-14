//
//  flickrResponse.swift
//  Virtual Tourist
//
//  Created by Ben Lewis on 10/14/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

struct PhotosResponse : Codable{
    let photos: VTPhotos
}

struct VTPhotos : Codable {
    let total: String
    let photos: [VTPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case photos = "photo"
    }
}

struct VTPhoto: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}
