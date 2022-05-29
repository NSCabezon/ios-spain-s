//
//  InternalTransferPreSetupUseCase.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 15/2/22.
//

import Foundation
import OpenCombine
import CoreDomain
import SANLegacyLibrary
import CoreFoundationLib

public struct PreSetupData {
    var originAccountsVisibles: [AccountRepresentable]
    var originAccountsNotVisibles: [AccountRepresentable]
    var destinationAccountsVisibles: [AccountRepresentable]
    var destinationAccountsNotVisibles: [AccountRepresentable]
    
    public init (originAccountsVisibles: [AccountRepresentable], originAccountsNotVisibles: [AccountRepresentable], destinationAccountsVisibles: [AccountRepresentable], destinationAccountsNotVisibles: [AccountRepresentable]) {
        self.originAccountsVisibles = originAccountsVisibles
        self.originAccountsNotVisibles = originAccountsNotVisibles
        self.destinationAccountsVisibles = destinationAccountsVisibles
        self.destinationAccountsNotVisibles = destinationAccountsNotVisibles
    }
}

public enum InternalTransferOperativeError: Error {
    case minimunAccounts
    case missingExchangeRatesResponse
    case genericError
    case network
}

public protocol InternalTransferPreSetupUseCase {
    
    func fetchPreSetup() -> AnyPublisher<PreSetupData, InternalTransferOperativeError>
}

struct DefaultInternalTransferPreSetupUseCase {
    let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: InternalTransferOperativeExternalDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultInternalTransferPreSetupUseCase: InternalTransferPreSetupUseCase {
    func fetchPreSetup() -> AnyPublisher<PreSetupData, InternalTransferOperativeError> {
        globalPositionRepository.getMergedGlobalPosition()
            .flatMap { userPref -> AnyPublisher<PreSetupData, InternalTransferOperativeError> in
                var originVisibles: [AccountRepresentable] = []
                var originNotVisibles: [AccountRepresentable] = []
                for account in userPref.accounts {
                    if account.isVisible {
                        originVisibles.append(account.product)
                    } else {
                        originNotVisibles.append(account.product)
                    }
                }
                if isMinimunAccounts(accounts: originVisibles + originNotVisibles) == false {
                    return Fail(error: InternalTransferOperativeError.minimunAccounts).eraseToAnyPublisher()
                }
                let data = PreSetupData(originAccountsVisibles: originVisibles, originAccountsNotVisibles: originNotVisibles, destinationAccountsVisibles: [], destinationAccountsNotVisibles: [])
                return Just(data).setFailureType(to: InternalTransferOperativeError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func isMinimunAccounts(accounts: [AccountRepresentable]) -> Bool {
        if accounts.count > 1 {
            return true
        } else {
            return false
        }
    }
}
