//
//  LoginTyped.swift
//  Models
//
//  Created by Juan Carlos López Robles on 11/17/20.
//

import SANLegacyLibrary

public enum LoginIdentityDocumentType: CaseIterable {
    case nif
    case nie
    case cif
    case passport
    case user
}

public extension LoginIdentityDocumentType {
    var dto: UserLoginType {
        switch self {
        case .nif:
            return .N
        case .nie:
            return .C
        case .cif:
            return .S
        case .passport:
            return .I
        case .user:
            return .U
        }
    }
    
    var metricsValue: String {
        switch self {
        case .nif:
            return "N"
        case .nie:
            return "C"
        case .cif:
            return "S"
        case .passport:
            return "I"
        case .user:
            return "U"
        }
    }
    
    var stringValue: String {
        switch self {
        case .nif:
            return "login_select_NIF"
        case .nie:
            return "login_select_NIE"
        case .cif:
            return "login_select_CIF"
        case .passport:
            return "login_select_passport"
        case .user:
            return "login_select_user"
        }
    }
}
