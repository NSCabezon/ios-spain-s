//
//  Authorization.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 01/07/2019.
//

import Foundation

public enum Authorization {
    
    case token(String)
    
    internal func headers() -> [String: String] {
        switch self {
        case .token(token: let token):
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    internal func token() -> String {
        switch self {
        case .token(let token):
            return token
        }
    }
}
