//
//  Activity.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//

import Foundation

struct ActivityResponse: Decodable {
    let results: [Activity]
}

struct Activity: Decodable, Hashable {
    let name: String
}
