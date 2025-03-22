//
//  TokenSearchView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 3/21/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import SwiftUI
import CoreData

struct TokenSearchView: View {
    @Binding var searchText: String
    let tokens: FetchedResults<TokenData>
    @Binding var codes: [String]
    @Binding var timeRemaining: Int
    let onDelete: (TokenData) -> Void
    
    var filteredTokens: [TokenData] {
        if searchText.isEmpty {
            return Array(tokens)
        }
        
        return tokens.filter { token in
            let issuerMatch = token.displayIssuer?.localizedCaseInsensitiveContains(searchText) ?? false
            let accountMatch = token.displayAccountName?.localizedCaseInsensitiveContains(searchText) ?? false
            return issuerMatch || accountMatch
        }
    }
    
    var body: some View {
        List {
            ForEach(Array(filteredTokens.enumerated()), id: \.element.id) { index, token in
                Section {
                    AuthCodeView(
                        token: Token(
                            id: token.id ?? "",
                            uri: token.uri ?? "",
                            displayIssuer: token.displayIssuer ?? "",
                            displayAccountName: token.displayAccountName ?? ""
                        ) ?? Token(),
                        totp: $codes[index],
                        timeRemaining: $timeRemaining,
                        onDelete: { onDelete(token) }
                    )
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search")
    }
}

