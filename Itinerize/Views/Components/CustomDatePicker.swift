//
//  CustomDatePicker.swift
//  Itinerize
//
//  Created by Moody on 2024-10-17.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var date: Date
    
    var body: some View {
        Text(date, style: .date)
            .font(.headline.bold().smallCaps())
            .padding(.top, 2)
            .overlay {
                DatePicker(selection: $date, displayedComponents: .date) {}
                    .labelsHidden()
                    .contentShape(Rectangle())
                    .colorMultiply(.clear)
            }
    }
}
