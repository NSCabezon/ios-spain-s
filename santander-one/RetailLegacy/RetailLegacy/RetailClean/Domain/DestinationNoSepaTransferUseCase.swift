import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class DestinationNoSepaTransferUseCase: UseCase<DestinationNoSepaTransferUseCaseInput, DestinationNoSepaTransferUseCaseOkOutput, DestinationNoSepaTransferUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(dependenciesResolver: DependenciesResolver, bsanManager: BSANManagersProvider) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = bsanManager
    }
    
    override func executeUseCase(requestValues: DestinationNoSepaTransferUseCaseInput) throws -> UseCaseResponse<DestinationNoSepaTransferUseCaseOkOutput, DestinationNoSepaTransferUseCaseErrorOutput> {
        let alias: String = requestValues.alias.trim()
        
        guard !requestValues.beneficiary.isEmpty else {
            return .error(DestinationNoSepaTransferUseCaseErrorOutput(.noToName))
        }
        guard let beneficiaryAccountValue = requestValues.beneficiaryAccountValue, !beneficiaryAccountValue.isEmpty else {
            return .error(DestinationNoSepaTransferUseCaseErrorOutput(.destinationAccounts))
        }
        if requestValues.saveFavorites {
            guard alias.count > 0 else {
                return .error(DestinationNoSepaTransferUseCaseErrorOutput(.noAlias))
            }
            let duplicate = requestValues.favouriteList.first { return $0.baoName?.trim() == alias.trim() }
            guard duplicate == nil else {
                return .error(DestinationNoSepaTransferUseCaseErrorOutput(.duplicateAlias(alias: alias)))
            }
        }
        guard requestValues.countryInfo.sepa && bankingUtils.isValidIban(ibanString: beneficiaryAccountValue) else {
            return .ok(DestinationNoSepaTransferUseCaseOkOutput(destinationNoSepaTransferUseCaseType: .noSepa, account: beneficiaryAccountValue, beneficiary: requestValues.beneficiary, noSepaTransferValidation: nil, newAlias: alias))
        }
        let noSepaTransferInput = requestValues.toNoSepaTransferInput(beneficiaryAccount: InternationalAccount(account: beneficiaryAccountValue), beneficiaryAddress: Address(country: requestValues.countryInfo.code))
        let response = try bsanManagersProvider.getBsanTransfersManager().validationIntNoSEPA(noSepaTransferInput: noSepaTransferInput, validationSwiftDTO: ValidationSwiftDTO())
        
        guard response.isSuccess(), let validation = try response.getResponseData() else {
            return .error(DestinationNoSepaTransferUseCaseErrorOutput(.serviceError(errorDesc: try response.getErrorMessage())))
        }
        
        return .ok(DestinationNoSepaTransferUseCaseOkOutput(destinationNoSepaTransferUseCaseType: .sepa, account: beneficiaryAccountValue, beneficiary: requestValues.beneficiary, noSepaTransferValidation: NoSepaTransferValidation(dto: validation, transferExpenses: requestValues.expensiveIndicator), newAlias: alias))
    }
}

struct DestinationNoSepaTransferUseCaseInput: NoSEPATransferInputConvertible {
    let originAccount: Account
    let beneficiary: String
    let beneficiaryAccountValue: String?
    let countryInfo: SepaCountryInfo
    let transferAmount: Amount
    let expensiveIndicator: NoSepaTransferExpenses
    let countryCode: String
    let concept: String
    let dateOperation: Date?
    let saveFavorites: Bool
    let favouriteList: [Favourite]
    let alias: String
}

struct DestinationNoSepaTransferUseCaseOkOutput {
    enum DestinationNoSepaTransferUseCaseType {
        case sepa
        case noSepa
    }
    
    let destinationNoSepaTransferUseCaseType: DestinationNoSepaTransferUseCaseType
    let account: String
    let beneficiary: String
    var noSepaTransferValidation: NoSepaTransferValidation?
    let newAlias: String
}

enum DestinationNoSepaTransferError {
    case destinationAccounts
    case noToName
    case noAlias
    case duplicateAlias(alias: String)
    case serviceError(errorDesc: String?)
}

class DestinationNoSepaTransferUseCaseErrorOutput: StringErrorOutput {
    let error: DestinationNoSepaTransferError
    
    init(_ error: DestinationNoSepaTransferError) {
        self.error = error
        super.init("")
    }
}
