//
//  Credential.swift
//  Authenticator
//
//  Created by Kel Reid on 1/27/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import Foundation

struct Credential: Identifiable, Codable {
    var id = UUID()
    var website: String
    var username: String
    var password: String
    var isEditing: Bool = false
}
