//
//  LoginUseCaseErrorOutput.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/18/20.
//

import Foundation
import CoreFoundationLib

public class LoginUseCaseErrorOutput: StringErrorOutput {
    public var loginErrorType: LoginErrorType?

    public init(loginErrorType: LoginErrorType?) {
        self.loginErrorType = loginErrorType
        super.init(nil)
    }

    public override init(_ errorDesc: String?) {
        self.loginErrorType = LoginErrorType.serviceFault
        super.init(errorDesc)
    }

    public func getLoginErrorType() -> LoginErrorType? {
        return loginErrorType
    }
}
