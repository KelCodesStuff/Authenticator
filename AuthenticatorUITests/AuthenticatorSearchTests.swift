//
//  AuthenticatorSearchTests.swift
//  AuthenticatorUITests
//
//  Created by Kel Reid on 3/21/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorSearchTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        
        // Enable biometric authentication in simulator
        if #available(iOS 13.0, *) {
            app.launchEnvironment["XCUITest_FASTLANE_SKIP_BIOMETRICS"] = "false"
        }        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        if app != nil {
            app = nil
        }
    }
    
    // MARK: - Helper Methods
    private func unlockApp() throws {
        let app = XCUIApplication()
        
        // Check if SetPasscodeView is present
        if app.navigationBars["Set Passcode"].exists {
            // Set a passcode
            let passcodeField1 = app.secureTextFields["Passcode"]
            passcodeField1.tap()
            passcodeField1.typeText("12345678")
            
            let passcodeField2 = app.secureTextFields["Confirm passcode"]
            passcodeField2.tap()
            passcodeField2.typeText("12345678")
            
            app.buttons["Start"].tap()
        }
        
        // Input Passcode View
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("12345678")
        
        let unlockButton = app.buttons["Unlock"]
        
        // Wait for unlock button to be enabled
        let startTime = Date()
        let timeout: TimeInterval = 20
        while !unlockButton.exists {
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Unlock button did not appear after \(timeout) seconds")
                return
            }
            sleep(1)
        }
        
        unlockButton.tap()
        
        // Wait for main view to appear
        let navBarTitle = app.staticTexts["Authenticator"]
        let navBarTitleLoaded = navBarTitle.waitForExistence(timeout: 15)
        XCTAssertTrue(navBarTitleLoaded, "Navigation bar title did not load in time")
    }
    
    // MARK: - Search Tests
    func testSearchIssuer() throws {
        try unlockApp()
        
        // Find and tap the search field
        let searchField = app.searchFields["Search"]
        let searchFieldExists = searchField.waitForExistence(timeout: 5)
        XCTAssertTrue(searchFieldExists, "Search field should exist")
        searchField.tap()
        
        // Search for "Philanthrophy"
        searchField.typeText("Philanthrophy")
        
        // Verify only Philanthrophy issuer is visible
        XCTAssertTrue(app.staticTexts["Philanthrophy"].exists)
        
        // Clear search
        searchField.buttons["Clear text"].tap()
        
        // Verify all issuers are visible again
        XCTAssertTrue(app.staticTexts["Apple"].exists)
        XCTAssertTrue(app.staticTexts["Google"].exists)
    }
    
    func testSearchAccountName() throws {
        try unlockApp()
        
        // Find and tap the search field
        let searchField = app.searchFields["Search"]
        let searchFieldExists = searchField.waitForExistence(timeout: 5)
        XCTAssertTrue(searchFieldExists, "Search field should exist")
        searchField.tap()
        
        // Search for "Otacon"
        searchField.typeText("Otacon")
        
        // Verify only Otacon account is visible
        XCTAssertFalse(app.staticTexts["Otacone"].exists)
        
        // Clear search
        searchField.buttons["Clear text"].tap()
        
        // Verify all accounts are visible again
        XCTAssertTrue(app.staticTexts["Solid Snake"].exists)
        XCTAssertTrue(app.staticTexts["Liquid Snake"].exists)
    }
    
    func testSearchNoResults() throws {
        try unlockApp()
        
        // Find and tap the search field
        let searchField = app.searchFields["Search"]
        let searchFieldExists = searchField.waitForExistence(timeout: 5)
        XCTAssertTrue(searchFieldExists, "Search field should exist")
        searchField.tap()
        
        // Search for account or issuer that doesn't exist
        searchField.typeText("NonExistentToken")
        
        // Verify no results are shown
        XCTAssertFalse(app.staticTexts["Apple"].exists)
        XCTAssertFalse(app.staticTexts["Google"].exists)
        XCTAssertFalse(app.staticTexts["Philanthrophy"].exists)
        
        // Clear search
        searchField.buttons["Clear text"].tap()
        
        // Verify all tokens are visible again
        XCTAssertTrue(app.staticTexts["Apple"].exists)
        XCTAssertTrue(app.staticTexts["Google"].exists)
        XCTAssertTrue(app.staticTexts["Philanthrophy"].exists)
    }
} 
