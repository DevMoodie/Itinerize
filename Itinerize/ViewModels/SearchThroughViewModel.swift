//
//  SearchThroughViewModel.swift
//  Itinerize
//
//  Created by Moody on 2024-10-08.
//

import Foundation
import Combine

class SearchThroughViewModel: ObservableObject {
    @Published var destination: String = "" {
        didSet {
            if destination.count > 2 && !isCitySelected {
                fetchCityOrCountrySuggestions(for: destination)
            } else {
                suggestions = []
            }
        }
    }
    @Published var suggestions: [String] = []
    @Published var isCitySelected: Bool = false
    
    
    @Published var startDate = Date()
    @Published var endDate = Date()
    
    @Published var selectedActivities: Set<String> = []
    @Published var selectedBudget = "$$"
    
    @Published var tripDuration = "3 Days"
    
    init() {
        startDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        endDate = Calendar.current.date(byAdding: .day, value: 3, to: startDate) ?? Date()
    }
    
    // Sample default recommendations (before the user types anything)
    let defaultRecommendation = ["New York", "Paris", "Egypt", "Japan"]
    let activityOptions = ["Sightseeing", "Adventure", "Beach", "Cultural", "Relaxation"]
    let budgetOptions = ["$", "$$", "$$$"]
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "YOUR_API_KEY"
    
    func fetchCityOrCountrySuggestions(for query: String) {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(query)&key=\(apiKey)") else {
            print("Invalid URL for suggestions.")
            return
        }

        // Create a set to track seen suggestions
        var seen = Set<String>()
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: PlaceAutocompleteResponse.self, decoder: JSONDecoder())
            .map { response in
                // Filter city and country results separately
                let cityResults = response.predictions
                    .filter { prediction in
                        prediction.types.contains("locality") && seen.insert(prediction.structured_formatting.main_text).inserted
                    }
                    .prefix(2) // Take the first 2 unique city results
                
                let countryResults = response.predictions
                    .filter { prediction in
                        prediction.types.contains("political") && seen.insert(prediction.structured_formatting.main_text).inserted
                    }
                    .prefix(2) // Take the first 2 unique country results
                
                // Combine city and country results
                let combinedResults = cityResults + countryResults
                print(combinedResults.prefix(4).map { $0.structured_formatting.main_text })
                
                // Return combined results, limiting to a total of 4 results
                return combinedResults.prefix(4).map { $0.structured_formatting.main_text }
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.suggestions, on: self)
            .store(in: &cancellables)
    }
    
    func selectCity(_ city: String) {
        self.isCitySelected = true
        self.destination = city
    }
}
