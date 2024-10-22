//
//  MainMenuView.swift
//  Itinerize
//
//  Created by Moody on 2024-10-08.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject var sTVM: SearchThroughViewModel = SearchThroughViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading) {
                    
                    // Destination
                    Text("Destination")
                        .font(.footnote.bold().smallCaps())
                        .padding(.top)
                    CustomTextField(placeholder: "Search for you next destination.", text: $sTVM.destination) {
                        if sTVM.destination != "" {
                            sTVM.destination = ""
                            sTVM.isCitySelected = false
                        }
                    } textfieldActive: {
                        sTVM.isCitySelected = false
                    }
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(.top)
                    
                    // Show suggestions or recommendations based on input
                    if !sTVM.suggestions.isEmpty {
                        SimpleWrapView(items: sTVM.suggestions) { suggestion in
                            sTVM.selectCity(suggestion)
                        }
                        .frame(height: UIScreen.main.bounds.size.height / 20.0)
                    } else if sTVM.destination.isEmpty {
                        SimpleWrapView(items: sTVM.defaultRecommendation) { recommendation in
                            sTVM.selectCity(recommendation)
                        }
                        .frame(height: UIScreen.main.bounds.size.height / 20.0)
                    } else {
                        SimpleWrapView(items: sTVM.defaultRecommendation) { recommendation in
                            sTVM.selectCity(recommendation)
                        }
                        .frame(height: UIScreen.main.bounds.size.height / 20.0)
                        .hidden()
                    }
                    
                    Divider()
                    
                    Text("Travel Dates")
                        .font(.footnote.bold().smallCaps())
                        .padding(.top, 5)
                    
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Start Date")
                                .font(.footnote.bold().smallCaps())
                            CustomDatePicker(date: $sTVM.startDate)
                                .onChange(of: sTVM.startDate) {
                                    if sTVM.startDate > sTVM.endDate {
                                        sTVM.endDate = Calendar.current.date(byAdding: .day, value: 3, to: sTVM.startDate) ?? Date()
                                    }
                                }
                        }
                        .padding(.bottom, 7)
                        
                        Spacer()
                        
                        CustomVerticalDivider()
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("End Date")
                                .font(.footnote.bold().smallCaps())
                            CustomDatePicker(date: $sTVM.endDate)
                                .onChange(of: sTVM.endDate) {
                                    if sTVM.endDate < sTVM.startDate {
                                        sTVM.endDate = Calendar.current.date(byAdding: .day, value: 3, to: sTVM.startDate) ?? Date()
                                    }
                                }
                        }
                        .padding(.bottom, 7)
                        
                        
                        Spacer()
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    // Activity Preferences
                    Text("Activity Preferences")
                        .font(.footnote.bold().smallCaps())
                        .padding(.top, 5)
                    
                    let columns = [
                        GridItem(.flexible(), spacing: 0),
                        GridItem(.flexible(), spacing: 0),
                        GridItem(.flexible(), spacing: 0)
                    ]
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
                        ForEach(sTVM.activityOptions, id: \.self) { activity in
                            ActivityPreferenceButtonView(activity: activity, isSelected: sTVM.selectedActivities.contains(activity)) {
                                if sTVM.selectedActivities.contains(activity) {
                                    sTVM.selectedActivities.remove(activity)
                                } else {
                                    sTVM.selectedActivities.insert(activity)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        // Budget Range
                        Text("Budget Range")
                            .font(.footnote.bold().smallCaps())
                        Spacer()
                        ForEach(sTVM.budgetOptions, id: \.self) { budget in
                            Button(action: {
                                sTVM.selectedBudget = budget
                            }) {
                                Text(budget)
                                    .font(.subheadline.smallCaps().bold())
                                    .foregroundColor(sTVM.selectedBudget == budget ? .white : .black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(sTVM.selectedBudget == budget ? Color.black : Color.clear)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.top, 5)
                    .padding(.trailing)
                    
                    NavigationLink(destination: ItineraryView(destination: sTVM.destination, startDate: sTVM.startDate, endDate: sTVM.endDate, preferences: Array(sTVM.selectedActivities), selectedBudget: sTVM.selectedBudget)) {
                        Text("Generate Itinerary")
                            .font(.headline.bold().smallCaps())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(35)
                    }
                    .padding(.horizontal, 55)
                    .padding(.top, 35)
                    .disabled(sTVM.destination == "" && sTVM.suggestions == [])
                    
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
            .navigationTitle("Plan your trip with Itinerize")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainMenuView()
}

