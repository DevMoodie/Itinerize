//
//  Extensions.swift
//  Itinerize
//
//  Created by Moody on 2024-10-10.
//

import Foundation
import UIKit

// Extension to calculate the size of text
extension String {
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attributes)
        return size
    }
}

extension Date {
    func toAPIDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

// Price formatting for convenience
extension MinPrice {
    func formattedPrice() -> String {
        return "\(units).\(nanos / 1000000)"
    }
}
