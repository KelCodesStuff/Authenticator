//
//  AnalyticsService.swift
//  Authenticator
//
//  Created by Kel Reid on 03/23/25
//

import Foundation
import FirebaseAnalytics

/// Enum defining all analytics events that can be logged in the app
/// Each case represents a specific user action or app state change
enum AnalyticsEvent {
    // MARK: - Authentication Events
    /// User successfully unlocked the app
    case appUnlocked
    /// User locked the app
    case appLocked
    /// User attempted biometric authentication (Face ID/Touch ID)
    case biometricAuthAttempted(success: Bool)
    /// User attempted passcode authentication
    case passcodeAttempted(success: Bool)
    /// User enabled biometric authentication
    case biometricEnabled
    /// User disabled biometric authentication
    case biometricDisabled
    /// User cancelled biometric setup
    case biometricSetupCancelled
    /// User completed biometric setup
    case biometricSetupCompleted
    /// User failed biometric setup
    case biometricSetupFailed
    
    // MARK: - Token Management Events
    /// New token was added to the app
    case tokenAdded(method: String) // "manual" or "scan"
    /// Token was deleted from the app
    case tokenDeleted
    /// Token was edited
    case tokenEdited
    /// Token code was copied to clipboard
    case tokenCopied
    /// Token was viewed by user
    case tokenViewed
    
    // MARK: - Search Events
    /// Search functionality was used
    case searchUsed
    
    // MARK: - Settings Events
    case settingsOpened
    /// Settings screen was closed
    
    // MARK: - Nav Button Events
    case qrScannerOpened
    /// Manual entry screen was opened
    case manualEntryOpened

    // MARK: - iCloud Backup Events
    case iCloudBackupEnabled
    /// iCloud backup was disabled
    case iCloudBackupDisabled
    /// iCloud backup failed
    case iCloudBackupFailed(reason: String)
    
    // MARK: - Error Events
    /// Generic error occurred
    case errorOccurred(type: String, message: String)
    /// QR code scanning failed
    case qrScanFailed(reason: String)
    /// Token validation failed
    case tokenValidationFailed(reason: String)
    
    // MARK: - UI Interaction Events
    /// Context menu was used
    case contextMenuUsed(action: String)
    /// Alert was shown to user
    case alertShown(type: String)
    
    /// Returns the Firebase Analytics event name for each case
    var name: String {
        switch self {
        case .appUnlocked: return "app_unlocked"
        case .appLocked: return "app_locked"
        case .biometricAuthAttempted: return "biometric_auth_attempted"
        case .passcodeAttempted: return "passcode_attempted"
        case .biometricEnabled: return "biometric_enabled"
        case .biometricDisabled: return "biometric_disabled"
        case .biometricSetupCancelled: return "biometric_setup_cancelled"
        case .biometricSetupCompleted: return "biometric_setup_completed"
        case .biometricSetupFailed: return "biometric_setup_failed"
        case .tokenAdded: return "token_added"
        case .tokenDeleted: return "token_deleted"
        case .tokenEdited: return "token_edited"
        case .tokenCopied: return "token_copied"
        case .tokenViewed: return "token_viewed"
        case .searchUsed: return "search_used"
        case .settingsOpened: return "settings_opened"
        case .qrScannerOpened: return "qr_scanner_opened"
        case .manualEntryOpened: return "manual_entry_opened"
        case .iCloudBackupEnabled: return "icloud_backup_enabled"
        case .iCloudBackupDisabled: return "icloud_backup_disabled"
        case .iCloudBackupFailed: return "icloud_backup_failed"
        case .errorOccurred: return "error_occurred"
        case .qrScanFailed: return "qr_scan_failed"
        case .tokenValidationFailed: return "token_validation_failed"
        case .contextMenuUsed: return "context_menu_used"
        case .alertShown: return "alert_shown"
        }
    }
    
    /// Returns the parameters to be sent with each event
    var parameters: [String: Any] {
        switch self {
        case .appUnlocked, .appLocked, .tokenDeleted, .tokenEdited, .tokenCopied, .tokenViewed, .searchUsed, .settingsOpened, .qrScannerOpened, .manualEntryOpened, .biometricEnabled, .biometricDisabled, .biometricSetupCancelled, .biometricSetupCompleted, .biometricSetupFailed, .iCloudBackupEnabled, .iCloudBackupDisabled:
            return [:]
            
        case .biometricAuthAttempted(let success), .passcodeAttempted(let success):
            return ["success": success]
            
        case .tokenAdded(let method):
            return ["method": method]
            
        case .errorOccurred(let type, let message):
            return [
                "error_type": type,
                "error_message": message
            ]
            
        case .qrScanFailed(let reason):
            return ["reason": reason]
            
        case .tokenValidationFailed(let reason):
            return ["reason": reason]
            
        case .contextMenuUsed(let action):
            return ["action": action]
            
        case .alertShown(let type):
            return ["alert_type": type]
            
        case .iCloudBackupFailed(let reason):
            return ["reason": reason]
        }
    }
}

/// Service responsible for handling all analytics logging in the app
class AnalyticsService {
    /// Shared instance for app-wide analytics access
    static let shared = AnalyticsService()
    
    private init() {}
    
    /// Logs an analytics event with its associated parameters
    /// - Parameter event: The analytics event to log
    func logEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
    
    // MARK: - Convenience Methods
    
    /// Logs when a new token is added
    /// - Parameter method: The method used to add the token ("manual" or "scan")
    func logTokenAdded(method: String) {
        logEvent(.tokenAdded(method: method))
    }
    
    /// Logs when a token is deleted
    func logTokenDeleted() {
        logEvent(.tokenDeleted)
    }
    
    /// Logs when a token code is copied
    func logTokenCopied() {
        logEvent(.tokenCopied)
    }
    
    /// Logs when an error occurs
    /// - Parameters:
    ///   - type: The type of error that occurred
    ///   - message: A description of the error
    func logError(type: String, message: String) {
        logEvent(.errorOccurred(type: type, message: message))
    }
    
    /// Logs when the context menu is used
    /// - Parameter action: The action performed from the context menu
    func logContextMenuAction(action: String) {
        logEvent(.contextMenuUsed(action: action))
    }
    
    /// Logs when an alert is shown
    /// - Parameter type: The type of alert shown
    func logAlertShown(type: String) {
        logEvent(.alertShown(type: type))
    }
    
    // MARK: - User Properties
    
    /// Sets user properties that persist across sessions
    /// - Parameters:
    ///   - tokenCount: The number of tokens in the app
    ///   - preferredAuthMethod: The user's preferred authentication method
    func setUserProperties(tokenCount: Int, preferredAuthMethod: String) {
        Analytics.setUserProperty(String(tokenCount), forName: "token_count")
        Analytics.setUserProperty(preferredAuthMethod, forName: "preferred_auth_method")
    }
} 
