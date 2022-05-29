//
//  LoginSessionErrorMessage.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/23/20.
//

import Foundation
import CoreFoundationLib

struct LoginSessionErrorMessage {
    func localizedError(_ error: LoadSessionError) -> LocalizedStylableText {
        switch error {
        case .generic, .unauthorized:
            return localized("pg_error_generic")
        case .networkUnavailable:
            return localized("generic_error_withoutConnection")
        case .intern:
           return localized("generic_error_app")
        case .other(let errorMessage):
           return LocalizedStylableText(text: errorMessage, styles: nil)
        }
    }
}
