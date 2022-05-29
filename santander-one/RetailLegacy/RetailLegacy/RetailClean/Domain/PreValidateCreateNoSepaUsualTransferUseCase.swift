import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class PreValidateCreateNoSepaUsualTransferUseCase: UseCase<PreValidateCreateNoSepaUsualTransferUseCaseInput, PreValidateCreateNoSepaUsualTransferUseCaseOkOutput, PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver

    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(bsanManagersProvider: BSANManagersProvider, dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = bsanManagersProvider
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreValidateCreateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<PreValidateCreateNoSepaUsualTransferUseCaseOkOutput, PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput> {        
        let transferManager = bsanManagersProvider.getBsanTransfersManager()
        let responseUsualTransfer = try transferManager.getUsualTransfers()
        guard responseUsualTransfer.isSuccess(), let dataUsualTransfer = try responseUsualTransfer.getResponseData() else {
            let error = ErrorDescriptionType.key("generic_error_txt")
            return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
        }
        let usualTransfers = dataUsualTransfer.map { Favourite.create($0) }
        guard let alias = requestValues.alias else {
            let error = ErrorDescriptionType.key("onePay_alert_alias")
            return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
        }
        guard usualTransfers.first(where: { $0.alias?.lowercased() == alias.lowercased() }) == nil else {
            let error = ErrorDescriptionType.keyWithPlaceHolder("onePay_alert_valueAlias", [StringPlaceholder(.value, alias)])
            return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
        }
        guard let beneficiaryName = requestValues.beneficiaryName else {
            let error = ErrorDescriptionType.key("onePay_alert_holderValidation")
            return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
        }
        guard let accountString = requestValues.account else {
            let error = ErrorDescriptionType.key("onePay_alert_destinationAccounts")
            return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
        }
        
        if requestValues.country.sepa {
            guard bankingUtils.isValidIban(ibanString: accountString) else {
                let error = ErrorDescriptionType.key("onePay_alert_valueIban")
                return .error(PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput(error))
            }
        }
        
        return .ok(PreValidateCreateNoSepaUsualTransferUseCaseOkOutput(account: accountString, alias: alias, beneficiaryName: beneficiaryName))
    }
}  

struct PreValidateCreateNoSepaUsualTransferUseCaseInput {
    let account: String?
    let beneficiaryName: String?
    let alias: String?
    let country: SepaCountryInfo
}

struct PreValidateCreateNoSepaUsualTransferUseCaseOkOutput {
    let account: String
    let alias: String
    let beneficiaryName: String
}

class PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput: StringErrorOutput {
    let errorInfo: ErrorDescriptionType
    
    init(_ error: ErrorDescriptionType) {
        self.errorInfo = error
        super.init(nil)
    }
}
