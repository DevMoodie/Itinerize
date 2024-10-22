//
//  CustomTextField.swift
//  Itinerize
//
//  Created by Moody on 2024-10-08.
//

import SwiftUI

struct CustomTextField: View {
    @State var placeholder: String
    @Binding var text: String
    
    var action: () -> Void
    var textfieldActive: () -> Void
    
    var body: some View {
        HStack {
            TextField("", text: $text, prompt: Text(placeholder).font(.footnote).foregroundStyle(.white.opacity(0.75)))
                .foregroundStyle(.white)
                .padding()
                .padding(.trailing)
            Button {
                action()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }
            .padding(.trailing)
        }
        .background(Color.black)
        .cornerRadius(25.0)
        .onChange(of: text) {
            textfieldActive()
        }
    }
}
