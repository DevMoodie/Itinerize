//
//  Car.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//

import Foundation

struct CarRentalResponse: Decodable {
    let cars: [CarRental]
}

struct CarRental: Decodable, Hashable {
    let name: String
    let price: String
}
