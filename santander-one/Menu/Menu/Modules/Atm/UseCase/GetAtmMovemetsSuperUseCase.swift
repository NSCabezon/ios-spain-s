//
//  GetFutureBillSuperUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 08/09/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

protocol GetAtmMovementsSuperUseCaseDelegate: AnyObject {
    func didFinishMovementsSuccessfully(with accountMovements: [AccountEntity: [AccountMovementRepresentable]])
    func didFinishMovementsWithError()
}

final class GetAtmMovementsSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var accountMovements: [AccountEntity: [AccountMovementRepresentable]] = [:]
    weak var delegate: GetAtmMovementsSuperUseCaseDelegate?
    
    func onSuccess() {
        self.delegate?.didFinishMovementsSuccessfully(with: self.accountMovements)
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishMovementsWithError()
    }
}

final class GetAtmMovemetsSuperUseCase: SuperUseCase<GetAtmMovementsSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handler: GetAtmMovementsSuperUseCaseDelegateHandler
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    weak var delegate: GetAtmMovementsSuperUseCaseDelegate? {
        get { return self.handler.delegate }
        set { self.handler.delegate = newValue }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handler = GetAtmMovementsSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handler)
    }
    
    override func setupUseCases() {
        if appConfigRepository.getBool("enableAtmZoneAccountMovements") ?? false {
            let accountUseCase = self.dependenciesResolver.resolve(for: GetAccountUseCase.self)
            self.add(accountUseCase) { result in
                result.accounts.forEach(self.loadMovementsForAccount)
            }
        } else {
            self.handler.onError(error: nil)
        }
    }
}

private extension GetAtmMovemetsSuperUseCase {
    func loadMovementsForAccount(_ account: AccountEntity) {
        let useCase = self.dependenciesResolver.resolve(for: GetMovementsAtmUseCase.self)
        let input = GetMovementsAtmUseCaseInput(account: account)
        self.add(useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
            self.handler.accountMovements[account] = result.movements
        }
        
    }
}
