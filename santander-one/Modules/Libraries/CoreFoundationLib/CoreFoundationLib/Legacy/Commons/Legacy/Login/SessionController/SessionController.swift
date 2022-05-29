//
//  SessionController.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation

public enum LoadSessionError: Error {
    case unauthorized
    case generic
    case networkUnavailable
    case intern
    case other(message: String)
}

public enum UserSessionState {
    case notLoggedIn
    case loggedIn
}
