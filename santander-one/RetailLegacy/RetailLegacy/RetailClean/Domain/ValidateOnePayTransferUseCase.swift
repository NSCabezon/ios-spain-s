import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateOnePaySanKeyTransferUseCase: UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type,
                                                     time: requestValues.time)
        let strategy = type.strategy(provider: provider,
                                     appConfigRepository: appConfigRepository,
                                     trusteerRepository: trusteerRepository,
                                     dependenciesResolver: dependenciesResolver)
        return try strategy.validateSanKeyTransfer(requestValues: requestValues)
    }
}

class ValidateOnePayTransferUseCase: UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type,
                                                     time: requestValues.time)
        let strategy = type.strategy(provider: provider,
                                     appConfigRepository: appConfigRepository,
                                     trusteerRepository: trusteerRepository,
                                     dependenciesResolver: dependenciesResolver)
        return try strategy.validateTransfer(requestValues: requestValues)
    }
}

struct ValidateOnePayTransferUseCaseInput: ScheduledTransferConvertible {
    let originAccount: Account
    let destinationIBAN: IBAN
    let name: String?
    let alias: String?
    let isSpanishResident: Bool
    let saveFavorites: Bool
    let beneficiaryMail: String?
    let amount: Amount
    let concept: String?
    let type: OnePayTransferType
    let subType: OnePayTransferSubType?
    let time: OnePayTransferTime
    let scheduledTransfer: ScheduledTransfer?
    let tokenPush: String?
}

struct ValidateOnePayTransferUseCaseOkOutput {
    let transferNational: TransferNational?
    let scheduledTransfer: ScheduledTransfer?
    let beneficiaryMail: String?
    let scaEntity: LegacySCAEntity
    
    init(transferNational: TransferNational? = nil, scheduledTransfer: ScheduledTransfer? = nil, beneficiaryMail: String?, scaEntity: LegacySCAEntity) {
        self.transferNational = transferNational
        self.scheduledTransfer = scheduledTransfer
        self.beneficiaryMail = beneficiaryMail
        self.scaEntity = scaEntity
    }
}

extension ValidateOnePayTransferUseCaseOkOutput: ValidateTransferUseCaseOkOutput {}
