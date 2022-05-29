//
//  LoadScheduledTransferSuperUseCase.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 2/10/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol ScheduledTransferSuperUseCaseDelegate: AnyObject {
    func didFinishSuccessfully(with transferList: ScheduledTransferListEntity)
    func didFinishWithError(_ error: String?)
}

final class ScheduledTransferSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var transfers: [AccountEntity: [ScheduledTransferEntity]] = [:]
    weak var delegate: ScheduledTransferSuperUseCaseDelegate?
    
    func onSuccess() {
        self.delegate?.didFinishSuccessfully(with: ScheduledTransferListEntity(transfers))
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishWithError(error)
    }
}

final class LoadScheduledTransferSuperUseCase: SuperUseCase<ScheduledTransferSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let handlerDelgete: ScheduledTransferSuperUseCaseDelegateHandler
    
    weak var delegate: ScheduledTransferSuperUseCaseDelegate? {
        get {
            return self.handlerDelgete.delegate
        } set {
            self.handlerDelgete.delegate = newValue
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelgete = ScheduledTransferSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        super.init(useCaseHandler: useCaseHandler, delegate: self.handlerDelgete)
    }
    
    override func setupUseCases() {
        let accountUseCase = self.dependenciesResolver.resolve(for: GetTransfersHomeUseCase.self)
        self.add(accountUseCase) { result in
            result.accounts.forEach(self.loadScheduledTransfersForAccount)
        }
    }
    
    private func loadScheduledTransfersForAccount(_ account: AccountEntity) {
        let useCase = self.dependenciesResolver.resolve(for: GetAllScheduledTransferUseCase.self)
        let input = GetAllScheduledTransferUseCaseInput(account: account, pagination: nil)
        self.add(useCase.setRequestValues(requestValues: input),
                 isMandatory: false) { result in
            self.handlerDelgete.transfers[account] = result.transfers
        }
    }
}
