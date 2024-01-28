//
//  Credential.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import Foundation

struct Credential: Identifiable, Codable {
    var id = UUID()
    var service: String
    var username: String
    var password: String
}
