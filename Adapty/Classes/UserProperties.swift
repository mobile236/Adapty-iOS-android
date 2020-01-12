//
//  UserProperties.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import AdSupport

class UserProperties {
    
    static let staticUuid = UUID().uuidString
    
    static var uuid: String {
        return UUID().uuidString
    }
    
    static var idfa: String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    static var sdkVersion: String? {
        return Bundle(for: Self.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var sdkVersionBuild: Int {
        return Constants.Versions.SDKBuild
    }
    
    static var appBuild: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var device: String {
        return UIDevice.modelName
    }
    
    static var locale: String {
        return Locale.current.identifier
    }
    
    static var OS: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    static var platform: String {
        return UIDevice.current.systemName
    }
    
    static var timezone: String {
        return TimeZone.current.identifier
    }
    
    static var deviceIdentifier: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
}
