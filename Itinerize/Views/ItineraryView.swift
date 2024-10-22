//
//  ItineraryView.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//


import SwiftUI

struct ItineraryView: View {
    @StateObject var itineraryVM = ItineraryViewModel()
    @Environment(\.dismiss) var dismiss
    
    let destination: String
    let startDate: Date
    let endDate: Date
    let preferences: [String]
    let selectedBudget: String
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text("Itinerary for \(destination)")
                        .font(.title3.bold().smallCaps())
                }
                HStack {
                    Text("Cancel")
                        .font(.footnote.bold().smallCaps())
                        .padding(.leading)
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                }
            }
            .padding()
            Spacer()
            if itineraryVM.isLoading {
                ProgressView {
                    Text("Creating your itinerary...")
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        // MARK: - Activities
                        
                        Text("Activities")
                            .font(.footnote.bold().smallCaps())
                            .padding(.top)
                        
                        let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 10)

                        // ScrollView with horizontal scrolling
                        ScrollView(.horizontal) {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                                ForEach(itineraryVM.activities, id: \.self) { activity in
                                    ActivityRow(activity: activity)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.vertical)
                        .scrollIndicators(.hidden)
                        
                        // MARK: - Flights
                        
                        Text("Flights")
                            .font(.footnote.bold().smallCaps())
                            .padding(.top)
                        
                        ScrollView(.horizontal) {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                                ForEach(itineraryVM.flights, id: \.self) { flight in
                                    FlightRow(flight: flight)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                                
                        // MARK: - Hotels
                        
                        Text("Stays")
                            .font(.footnote.bold().smallCaps())
                            .padding(.top)
                        
                        ScrollView(.horizontal) {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                                ForEach(itineraryVM.hotels, id: \.self) { hotel in
                                    HotelRow(hotel: hotel)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            itineraryVM.fetchItinerary(for: destination, startDate: startDate, endDate: endDate, preferences: preferences)
        }
    }
}

// Custom row views for displaying each section's data
struct FlightRow: View {
    let flight: FlightOffer
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(flight.segments.first?.departureAirport.city ?? "Unknown") to \(flight.segments.first?.arrivalAirport.city ?? "Unknown")")
                .font(.headline.smallCaps().bold())
                .foregroundColor(.white)
            if let priceDouble = Double(flight.priceBreakdown.total.formattedPrice()) {
                let roundedPrice = Int(round(priceDouble))
                let roundedPriceString = String(roundedPrice)
                Text("Price: \(roundedPriceString)")
                    .font(.subheadline.smallCaps().bold())
                    .foregroundColor(.white)
            } else {
                Text("Price: \(flight.priceBreakdown.total.formattedPrice())")
                    .font(.subheadline.smallCaps().bold())
                    .foregroundColor(.white)
            }
            Text("Airline: \(flight.segments.first?.legs.first?.carriersData.first?.name ?? "Unknown")")
                .font(.subheadline.smallCaps().bold())
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.black)
        .cornerRadius(20)
    }
}

struct HotelRow: View {
    let hotel: HotelDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hotel: \(hotel.hotel_name)")
                .font(.headline.smallCaps().bold())
                .foregroundColor(.white)
            let price = hotel.product_price_breakdown.gross_amount_per_night
            let roundedPrice = Int(round(price.value))
            let roundedPriceString = String(roundedPrice)
            Text("Price: \(roundedPriceString) \(price.currency)")
                .font(.headline.smallCaps().bold())
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.black)
        .cornerRadius(20)
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        Text(activity.name)
            .font(.caption.smallCaps().bold())
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.black)
            .cornerRadius(20)
    }
}

struct CarRentalRow: View {
    let carRental: CarRental
    var body: some View {
        VStack(alignment: .leading) {
            Text("Car Rental: \(carRental.name)")
            Text("Price: \(carRental.price)")
        }
        .padding()
    }
}
