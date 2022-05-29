//
//  GetUserTypeHelper.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 23/4/21.
//

import SANLegacyLibrary
import CoreFoundationLib

public protocol UserTypeVerifierHelperDelegate: AnyObject {
    func loginTypeUser()
    func loginTypeNoUser()
}

public final class UserTypeVerifierHelper {
    // MARK: - Properties
    private let dependenciesResolver: DependenciesResolver
    private weak var delegate: UserTypeVerifierHelperDelegate?
    private var usecaseHandler: UseCaseHandler {
        dependenciesResolver.resolve()
    }
    
    // MARK: - Initializer
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public init(dependenciesResolver: DependenciesResolver, delegate: UserTypeVerifierHelperDelegate?) {
        self.dependenciesResolver = dependenciesResolver
        self.delegate = delegate
    }
    
    // MARK: - Public methods
    
    public func askForUserLoginType() {
        Scenario(useCase: GetLoginTypeUseCase(dependenciesResolver: self.dependenciesResolver))
            .execute(on: self.usecaseHandler)
            .onSuccess { [weak self] output in
                if output.loginType == UserLoginType.U {
                    self?.delegate?.loginTypeUser()
                } else {
                    self?.delegate?.loginTypeNoUser()
                }
            }
    }
}
