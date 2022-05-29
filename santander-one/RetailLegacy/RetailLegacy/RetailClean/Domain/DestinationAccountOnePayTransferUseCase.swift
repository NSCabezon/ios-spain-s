import CoreFoundationLib
import SANLegacyLibrary
import Foundation

class DestinationAccountOnePayTransferUseCase: UseCase<DestinationAccountOnePayTransferUseCaseInput, DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
    
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
    
    override func executeUseCase(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type, time: requestValues.time)
        let strategy = type.strategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
        return try strategy.preValidateDestinationAccount(requestValues: requestValues)
    }
}

struct DestinationAccountOnePayTransferUseCaseInput: ScheduledTransferConvertible, IBANValidable {
    let iban: String?
    let name: String?
    let alias: String?
    let saveFavorites: Bool
    let isSpanishResident: Bool
    let time: OnePayTransferTime
    let favouriteList: [Favourite]
    let country: SepaCountryInfo
    let type: OnePayTransferType
    let concept: String?
    let amount: Amount
    let originAccount: Account
    let scheduledTransfer: ScheduledTransfer?
}

struct DestinationAccountOnePayTransferUseCaseOkOutput {
    let iban: IBAN
    let name: String
    let alias: String?
    let saveFavorites: Bool
    let time: OnePayTransferTime
    let transferNational: TransferNational?
    let scheduledTransfer: ScheduledTransfer?
}

enum DestinationAccountOnePayTransferError {
    case ibanInvalid
    case noToName
    case noAlias
    case duplicateAlias(alias: String)
    case serviceError(errorDesc: String?)
}

class DestinationAccountOnePayTransferUseCaseErrorOutput: StringErrorOutput {
    let error: DestinationAccountOnePayTransferError
    
    init(_ error: DestinationAccountOnePayTransferError) {
        self.error = error
        super.init("")
    }
}
