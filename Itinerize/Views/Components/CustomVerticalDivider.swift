//
//  Untitled.swift
//  Itinerize
//
//  Created by Moody on 2024-10-17.
//

import SwiftUI

struct CustomVerticalDivider: View {
    var body: some View {
        Rectangle()
            .fill(.black)
            .frame(width: 3)
            .edgesIgnoringSafeArea(.vertical)
    }
}
