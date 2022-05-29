//
//  LocalValidation.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/18/20.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib
import ESCommons

public protocol LocalValidationProtocol {
    func validate(userLoginType: UserLoginType?, login: String?, pass: String?) -> LoginErrorType?
}

public class LocalValidation: LocalValidationProtocol {
    static let minPasswordLength: Int = 4
    private let dependenciesResolver: DependenciesResolver
    private let appConfig: AppConfigRepositoryProtocol
    private let demoInterpreter: DemoInterpreterProtocol
    private let documentValidator: DocumentValidator
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.demoInterpreter = self.dependenciesResolver.resolve(for: DemoInterpreterProtocol.self)
        self.documentValidator = self.dependenciesResolver.resolve(for: DocumentValidator.self)
    }
    
    public func validate(userLoginType: UserLoginType?, login: String?, pass: String?) -> LoginErrorType? {
        let appActive = self.appConfig.getBool(LoginConstants.appConfigActive) ?? false
        guard appActive else {
            let activeMessage: String = self.appConfig.getString(LoginConstants.appConfigActiveMessage) ?? ""
            return .versionBlocked(error: activeMessage)
        }
        
        var loginPreFormatted: String = login != nil ? login!.trim() : ""
        
        // usuario demo
        guard !demoInterpreter.isDemoUser(userName: loginPreFormatted.uppercased()) else { return nil }
        guard !loginPreFormatted.isEmpty else { return .emptyNumDoc}
        guard let pass = pass, !pass.isEmpty else { return .emptyPass }
        guard pass.count >= LocalValidation.minPasswordLength else { return .passTooShort }
        guard let userLoginType = userLoginType else { return .noNumDoc }
        
        loginPreFormatted = loginPreFormatted.uppercased()
        
        switch userLoginType {
        case UserLoginType.N:
            if !validate(document: loginPreFormatted) {
                return .docNoValid
            }
        case UserLoginType.C:
            if !validate(document: loginPreFormatted) {
                return .docNoValid
            }
        case UserLoginType.I, UserLoginType.S, UserLoginType.U:
            break
        }
        return nil
    }
    
    private func validate(document: String?) -> Bool {
        guard let document = document else { return false }
        return document.count >= 9 && documentValidator.validate(document)
    }
    
    private func isEmpty(_ string: String?) -> Bool {
        return string == nil || string!.isEmpty
    }
}
