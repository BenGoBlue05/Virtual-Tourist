//
//  VTResult.swift
//  Virtual Tourist
//
//  Created by Ben Lewis on 10/14/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import Foundation

enum VTResult<T> {
    case success(T)
    case error(String)
}

struct VTErrorResponse : Codable {
    let message: String?
}
