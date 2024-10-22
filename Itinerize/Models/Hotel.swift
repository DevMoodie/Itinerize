//
//  Hotel.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//

import Foundation

struct DestinationResponse: Codable {
    let data: [Destination]
}

struct Destination: Codable {
    let dest_id: String
    let search_type: String
}

struct HotelSearchResponse: Codable {
    let data: HotelData
}

struct HotelData: Codable {
    let hotels: [Hotel]
}

struct Hotel: Codable {
    let hotel_id: Int
}

struct HotelDetailsResponse: Codable {
    let data: HotelDetails
}

struct HotelDetails: Codable, Hashable {
    let hotel_name: String
    let currency_code: String
    let product_price_breakdown: HotelPrice
}

struct HotelPrice: Codable, Hashable {
    let gross_amount_per_night: Price
}

struct Price: Codable, Hashable {
    let currency: String
    let value: Double
}
