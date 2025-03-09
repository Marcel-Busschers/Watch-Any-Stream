//
//  Errors.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//

import Foundation

enum NilError: Error, LocalizedError {
    case nilName
    case nilType
    
    var errorDescription: String? {
        switch self {
            case .nilName: return "String cannot be nil"
            case .nilType: return "Type is nil"
        }
    }
}

enum ConfigError: Error, LocalizedError {
    case fileNotFound
    case keyNotFound
    case invalidValue
    
    var errorDescription: String? {
        switch self {
            case .fileNotFound: return "Error: Config.plist file not found."
            case .keyNotFound: return "Error: API_KEY not found in Config.plist."
            case .invalidValue: return "Error: Invalid value in Config.plist."
        }
    }
}

enum RequestTypeError: Error, LocalizedError {
    case prohibited
    
    var errorDescription: String? {
        switch self {
            case .prohibited: return "Error: May not use this RequestType."
        }
    }
}
