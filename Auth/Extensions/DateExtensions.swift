//
//  DateExtensions.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import Foundation

extension Date {
        private static let formatter: DateFormatter = {
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd-HHmmss"
                return formatter
        }()
        static var currentDateText: String {
                let text: String = Date.formatter.string(from: Date())
                return text
        }
}
