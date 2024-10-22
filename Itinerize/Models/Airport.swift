//
//  Airport.swift
//  Itinerize
//
//  Created by Moody on 2024-10-17.
//

import Foundation

struct AirportResponse: Codable {
    let status: Bool
    let message: String
    let data: [Airport]
}

struct Airport: Codable {
    let id: String
    let type: String
    let name: String
    let code: String
    let city: String?         // Some airports may not have a city key
    let cityName: String?     // Make cityName optional to handle cases where it's missing
    let regionName: String?
    let country: String
    let countryName: String
    let photoUri: String
    let distanceToCity: DistanceToCity?
}

struct DistanceToCity: Codable {
    let value: Double
    let unit: String
}
