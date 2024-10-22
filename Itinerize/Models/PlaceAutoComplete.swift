//
//  PlaceAutoComplete.swift
//  Itinerize
//
//  Created by Moody on 2024-10-08.
//

import Foundation

struct PlaceAutocompleteResponse: Codable, Hashable {
    let predictions: [Prediction]
}

struct Prediction: Codable, Hashable {
    let structured_formatting: StructuredFormatting
    let description: String
    let types: [String]
}

struct StructuredFormatting: Codable, Hashable {
    let main_text: String  // This is the city name
}
