//
//  GetFutureBillSuperUseCase.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

protocol GetFutureBillSuperUseCaseDelegateDelegate: AnyObject {
    func didFinishFutureBillSuccessfully(with accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]])
}

final class GetFutureBillSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var accountFutureBills: [AccountEntity: [AccountFutureBillRepresentable]] = [:]
    weak var delegate: GetFutureBillSuperUseCaseDelegateDelegate?
    
    func onSuccess() {
        self.delegate?.didFinishFutureBillSuccessfully(with: self.accountFutureBills)
    }
    
    func onError(error: String?) { }
}

final class GetFutureBillSuperUseCase: SuperUseCase<GetFutureBillSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handlerDelegate: GetFutureBillSuperUseCaseDelegateHandler
    
    weak var delegate: GetFutureBillSuperUseCaseDelegateDelegate? {
        get { return self.handlerDelegate.delegate }
        set { self.handlerDelegate.delegate = newValue }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelegate = GetFutureBillSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelegate)
    }
    
    override func setupUseCases() {
        let accountUseCase = self.dependenciesResolver.resolve(for: GetAccountUseCase.self)
        self.add(accountUseCase) { result in
            result.accounts.forEach(self.loadFutureBillForAccount)
        }
    }
}

private extension GetFutureBillSuperUseCase {
    func loadFutureBillForAccount(_ account: AccountEntity) {
        let useCase = self.dependenciesResolver.resolve(for: GetFutureBillUseCase.self)
        let input = GetFutureBillUseCaseInput(account: account)
        self.add(useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
            self.handlerDelegate.accountFutureBills[account] = result.futureBills
        }
    }
}
