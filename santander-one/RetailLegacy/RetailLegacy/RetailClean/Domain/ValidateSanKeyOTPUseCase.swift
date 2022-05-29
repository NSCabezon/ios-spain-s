//
//  ValidateSanKeyOTPUseCase.swift
//  RetailLegacy
//
//  Created by Andres Aguirre Juarez on 26/10/21.
//

import SANLegacyLibrary
import CoreFoundationLib

class ValidateSanKeyOTPUseCase: ConfirmUseCase<ConfirmOnePayTransferUseCaseInput, ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type,
                                                     time: requestValues.time)
        let strategy = type.strategy(provider: provider,
                                     appConfigRepository: appConfigRepository,
                                     trusteerRepository: trusteerRepository,
                                     dependenciesResolver: dependenciesResolver)
        return try strategy.confirmSanKeyTransfer(requestValues: requestValues)
    }
}
