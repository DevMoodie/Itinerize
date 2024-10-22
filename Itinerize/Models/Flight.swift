import Foundation

// Main Response
struct FlightSearchResponse: Codable, Hashable {
    let data: FlightData
}

struct FlightData: Codable, Hashable {
    let flightOffers: [FlightOffer]
}

// Flight Offer Structure
struct FlightOffer: Codable, Hashable {
    let token: String
    let segments: [FlightSegment]
    let priceBreakdown: PriceBreakdown
}

// Flight Segment Structure
struct FlightSegment: Codable, Hashable {
    let departureAirport, arrivalAirport: AirportInfoForFlight
    let departureTime, arrivalTime: String
    let legs: [Leg]
    let travellerCabinLuggage: [TravellerCabinLuggage]
}

struct Leg: Codable, Hashable {
    let departureTime, arrivalTime: String
    let departureAirport, arrivalAirport: AirportInfoForFlight
    let cabinClass: String
    let flightInfo: FlightInfo
    let carriersData: [Carrier]
    let totalTime: Int
    let departureTerminal, arrivalTerminal: String?
}

struct Carrier: Codable, Hashable {
    let name: String
    let code: String
    let logo: String
}

struct FlightInfo: Codable, Hashable {
    let flightNumber: Int
    let planeType: String
}

// Airport Information
struct AirportInfoForFlight: Codable, Hashable {
    let code: String
    let city: String
    let name: String
}

// Price Structure
struct PriceBreakdown: Codable, Hashable {
    let total: MinPrice
}

struct MinPrice: Codable, Hashable {
    let currencyCode: CurrencyCode
    let units, nanos: Int
}

enum CurrencyCode: String, Codable {
    case cad = "CAD"
}

struct TravellerCabinLuggage: Codable, Hashable {
    let luggageAllowance: LuggageAllowanceElement
    let personalItem: Bool?
}

// Luggage Allowance
struct LuggageAllowanceElement: Codable, Hashable {
    let luggageType: LuggageType
    let maxPiece: Int
    let piecePerPax: Int?
    let sizeRestrictions: SizeRestrictions?
}

enum LuggageType: String, Codable {
    case hand = "HAND"
    case personalItem = "PERSONAL_ITEM"
}

struct SizeRestrictions: Codable, Hashable {
    let maxLength, maxWidth, maxHeight: Double
    let sizeUnit: SizeUnit
}

enum SizeUnit: String, Codable {
    case inch = "INCH"
}
