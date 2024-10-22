//
//  WrapView.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//

import SwiftUI
import UIKit

// Simple view for wrapping suggestions into multiple rows
struct SimpleWrapView: View {
    let items: [String]
    let action: (String) -> Void
    
    var body: some View {
        // Use a VStack to organize rows and LazyHStack to arrange items horizontally
        HStack (alignment: .center) {
            Spacer()
            
            ForEach(items, id: \.self) { item in
                Button {
                    action(item)
                } label: {
                    Text(item)
                        .font(.caption.smallCaps().bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black)
                        .cornerRadius(20)
                }
            }
            
            Spacer()
        }
        .padding(.top, 5)
    }
}

struct ActivityPreferenceButtonView: View {
    let activity: String
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(activity)
                .font(.caption.smallCaps().bold())
                .foregroundColor(isSelected ? .white : .black)
                .frame(width: UIScreen.main.bounds.size.width / 5.5)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.black : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                )
        }
    }
}
