//
//  CustomVerticalDivider 2.swift
//  Itinerize
//
//  Created by Moody on 2024-10-17.
//


import SwiftUI

struct CustomHorizonatalDivider: View {
    var body: some View {
        Rectangle()
            .fill(.black.opacity(0.54))
            .frame(height: 2)
            .edgesIgnoringSafeArea(.horizontal)
            .padding()
    }
}
