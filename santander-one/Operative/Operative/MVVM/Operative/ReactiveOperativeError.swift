//
//  ReactiveOperativeError.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 1/2/22.
//

import Foundation

public enum ReactiveOperativeError: LocalizedError {
    
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .unknown: return "unknown"
        }
    }
}
