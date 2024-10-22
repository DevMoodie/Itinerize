//
//  ItineraryViewModel.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//


import Foundation
import Combine

import CoreLocation

class ItineraryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var flights: [FlightOffer] = []
    @Published var hotels: [HotelDetails] = []
    @Published var activities: [Activity] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // Example API Keys (replace with your actual keys)
    private let bookingAPIKey = "166325cfa9mshb0300d416004951p11da8fjsnb5d771eaab3b"
    private let apiHost = "booking-com15.p.rapidapi.com"
    private let googlePlacesAPIKey = "AIzaSyD0hr6htOUZr9kUY3PZyfskrGJ0GBNNMJE"
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    
    @Published var locationDenied = false
    
    @Published var isLoading: Bool = false
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Delegate method to update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location
        }
    }

    // Delegate method to handle permission changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            print("Location denied...")
            locationDenied = true
        default:
            print("Location Fetched!")
            locationDenied = false
        }
    }
    
    // Delegate method for handling location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    // MARK: - Fetch Itinerary Data
    func fetchItinerary(for destination: String, startDate: Date, endDate: Date, preferences: [String]) {
        Task {
            await fetchFlights(to: destination, startDate: startDate.toAPIDateFormat(), endDate: endDate.toAPIDateFormat())
            fetchHotels(for: destination, startDate: startDate.toAPIDateFormat(), endDate: endDate.toAPIDateFormat())
            fetchActivities(for: destination, preferences: preferences)
        }
    }
    
    // MARK: - Flight API Call (Sky Scanner)
    private func fetchFlights(to destination: String, startDate: String, endDate: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Fetch destination airport code
        let destinationAirportCode = await fetchAirportCode(for: destination)
        print("Fetch Destination Airport Code: \(destinationAirportCode)")
        
        // Check if user location is available
        guard let location = userLocation else {
            print("User location not available.")
            return
        }
        
        // Fetch origin airport code based on user location
        let originAirportCode = await fetchNearestAirportCode(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        print("Fetch Origin Airport Code: \(originAirportCode)")
        
        // Log start and end date
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        
        // Construct URL for the API request
        guard let url = URL(string: "https://booking-com15.p.rapidapi.com/api/v1/flights/searchFlights?fromId=\(originAirportCode)&toId=\(destinationAirportCode)&departDate=\(startDate)&returnDate=\(endDate)&pageNo=1&adults=1&children=0%2C17&sort=CHEAPEST&cabinClass=ECONOMY&currency_code=CAD") else {
            print("Fetching Flights API URL Error: Returning")
            return
        }
        
        print("Flights API URL: \(url.absoluteString)")
        
        // Create request and set headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(bookingAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: FlightSearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished receiving flights data.")
                    
                case .failure(let error):
                    print("Failed to fetch flights: \(error.localizedDescription)")
                    // Optionally, print out more details about the error
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("Type mismatch error: \(type) - \(context.debugDescription)")
                        case .valueNotFound(let value, let context):
                            print("Value not found: \(value) - \(context.debugDescription)")
                        case .keyNotFound(let key, let context):
                            print("Key not found: \(key) - \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("Unknown decoding error")
                        }
                    } else {
                        print("Other error: \(error.localizedDescription)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }, receiveValue: { [weak self] flightSearchResponse in
                // Assign the parsed flights to the @Published property
                self?.flights = flightSearchResponse.data.flightOffers
                print("Fetched \(self?.flights.count ?? 0) flights.")
            })
            .store(in: &cancellables)
    }

    
    private func fetchNearestAirportCode(latitude: Double, longitude: Double) async -> String {
        let headers = [
            "x-rapidapi-key": bookingAPIKey,
            "x-rapidapi-host": apiHost
        ]
        
        // Use reverse geocoding to get city or region name from lat/lon
        let geocoder = CLGeocoder()
        var cityName: String = ""
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first, let city = placemark.locality {
                print("Origin City: \(city)")
                cityName = city
            } else {
                print("Failed to get city name from coordinates")
                return ""
            }
        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
            return ""
        }
        
        // Construct the URL using the coordinates
        guard let url = URL(string: "https://booking-com15.p.rapidapi.com/api/v1/flights/searchDestination?query=\(cityName)") else {
            return ""
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Proceed with decoding after you check the structure
            let response = try JSONDecoder().decode(AirportResponse.self, from: data)
            
            return response.data.first(where: { $0.type == "AIRPORT" })?.id ?? "YYZ.AIRPORT"  // Return the IATA code of the nearest airport

        } catch {
            print("Failed to fetch IATA code: \(error)")
            return ""
        }
    }
    
    private func fetchAirportCode(for city: String) async -> String {
        let headers = [
            "x-rapidapi-key": bookingAPIKey,
            "x-rapidapi-host": apiHost
        ]
        
        // Remove spaces from city
        let cityName = city.filter { !" \n\t\r".contains($0) }
        print("Destination City: \(cityName)")
        
        // Construct the URL using the city name
        guard let url = URL(string: "https://booking-com15.p.rapidapi.com/api/v1/flights/searchDestination?query=\(cityName)") else {
            return ""
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(AirportResponse.self, from: data)
            
            return response.data.first(where: { $0.type == "AIRPORT" })?.id ?? "LAX.AIRPORT"  // Return the IATA code for the city
        } catch {
            print("Failed to fetch IATA code for city \(city): \(error)")
            return ""
        }
    }

    
    // MARK: - Activity API Call (Google Places)
    
    private func fetchActivities(for destination: String, preferences: [String]) {
        let preferenceString = preferences.joined(separator: "|")
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=things+to+do+in+\(destination)&types=\(preferenceString)&key=\(googlePlacesAPIKey)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ActivityResponse.self, decoder: JSONDecoder())
            .replaceError(with: ActivityResponse(results: []))
            .receive(on: DispatchQueue.main)
            .map { $0.results }
            .assign(to: \.activities, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Hotel API Call (Booking)
    
    private func fetchHotels(for destination: String, startDate: String, endDate: String) {
        searchHotelDestination(destination: destination)
            .flatMap { destination -> AnyPublisher<[Hotel], Error> in
                let firstDestination = destination.data.first!
                return self.searchHotels(dest_id: firstDestination.dest_id, search_type: firstDestination.search_type, startDate: startDate, endDate: endDate)
            }
            .flatMap { hotels -> AnyPublisher<[HotelDetails], Error> in
                let hotelDetailsPublishers = hotels.map { hotel in
                    self.fetchHotelDetails(hotel_id: hotel.hotel_id, startDate: startDate, endDate: endDate)
                }
                return Publishers.MergeMany(hotelDetailsPublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error)")
                case .finished:
                    print("Finished fetching hotel details")
                }
            } receiveValue: { hotelDetails in
                hotelDetails.forEach { details in
                    let price = details.product_price_breakdown.gross_amount_per_night
                    print("Hotel: \(details.hotel_name), Price: \(price.value), Currency: \(price.currency)")
                    DispatchQueue.main.async {
                        self.hotels.append(HotelDetails(hotel_name: details.hotel_name, currency_code: details.currency_code, product_price_breakdown: details.product_price_breakdown))
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // Search for a destination
    private func searchHotelDestination(destination: String) -> AnyPublisher<DestinationResponse, Error> {
        let cityName = destination.filter { !" \n\t\r".contains($0) }
        let urlString = "https://\(apiHost)/api/v1/hotels/searchDestination?query=\(cityName)"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue(bookingAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: DestinationResponse.self, decoder: JSONDecoder()) // Ensure this matches your structure
            .eraseToAnyPublisher()
    }
    
    private func searchHotels(dest_id: String, search_type: String, startDate: String, endDate: String) -> AnyPublisher<[Hotel], Error> {
        let urlString = "https://\(apiHost)/api/v1/hotels/searchHotels?dest_id=\(dest_id)&search_type=\(search_type)&arrival_date=\(startDate)&departure_date=\(endDate)&adults=2&room_qty=1&page_number=1&units=metric&temperature_unit=c&languagecode=en-us&currency_code=CAD"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue(bookingAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: HotelSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                Array(response.data.hotels.prefix(10)) // Get the first 10 hotels
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchHotelDetails(hotel_id: Int, startDate: String, endDate: String) -> AnyPublisher<HotelDetails, Error> {
        let urlString = "https://\(apiHost)/api/v1/hotels/getHotelDetails?hotel_id=\(hotel_id)&arrival_date=\(startDate)&departure_date=\(endDate)&adults=1&room_qty=2&units=metric&temperature_unit=c&languagecode=en-us&currency_code=CAD"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue(bookingAPIKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: HotelDetailsResponse.self, decoder: JSONDecoder())
            .map { response in
                response.data
            }
            .eraseToAnyPublisher()
    }
}
