import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class PreValidateCreateUsualTransferUseCase: UseCase<PreValidateCreateUsualTransferUseCaseInput, PreValidateCreateUsualTransferUseCaseOkOutput, PreValidateCreateUsualTransferUseCaseErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreValidateCreateUsualTransferUseCaseInput) throws -> UseCaseResponse<PreValidateCreateUsualTransferUseCaseOkOutput, PreValidateCreateUsualTransferUseCaseErrorOutput> {
        
        let country = requestValues.country
        
        let transferManager = bsanManagersProvider.getBsanTransfersManager()
        let responseUsualTransfer = try transferManager.getUsualTransfers()
        guard responseUsualTransfer.isSuccess(), let dataUsualTransfer = try responseUsualTransfer.getResponseData() else {
            let error = ErrorDescriptionType.key("generic_error_txt")
            return UseCaseResponse.error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
        let usualTransfers = dataUsualTransfer.map { Favourite.create($0) }
        guard let alias = requestValues.alias else {
            let error = ErrorDescriptionType.key("onePay_alert_alias")
            return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
        guard usualTransfers.first(where: { $0.alias?.lowercased() == alias.lowercased() }) == nil else {
            let error = ErrorDescriptionType.keyWithPlaceHolder("onePay_alert_valueAlias", [StringPlaceholder(.value, alias)])
            return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
        guard let beneficiaryName = requestValues.beneficiaryName else {
            let error = ErrorDescriptionType.key("onePay_alert_holderValidation")
            return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
        guard let ibanString = requestValues.iban else {
            let error = ErrorDescriptionType.key("onePay_alert_valueIban")
            return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
        
        let strategy: TransferStrategy
        switch requestValues.country.code {
        case "ES":
            strategy = NationalTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        default:
            strategy = SepaTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
        }
        
        switch strategy.ibanValidation(requestValues: requestValues) {
        case .ok(let iban):
            guard bankingUtils.isValidIban(ibanString: ibanString) else {
                let error = ErrorDescriptionType.key("onePay_alert_valueIban")
                return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
            }
            return .ok(PreValidateCreateUsualTransferUseCaseOkOutput(iban: iban, alias: alias, beneficiaryName: beneficiaryName))
        case .error:
            let error = ErrorDescriptionType.key("onePay_alert_valueIban")
            return .error(PreValidateCreateUsualTransferUseCaseErrorOutput(error))
        }
    }
}

struct PreValidateCreateUsualTransferUseCaseInput: IBANValidable {
    let iban: String?
    let beneficiaryName: String?
    let alias: String?
    let country: SepaCountryInfo
}

struct PreValidateCreateUsualTransferUseCaseOkOutput {
    let iban: IBAN
    let alias: String
    let beneficiaryName: String
}

class PreValidateCreateUsualTransferUseCaseErrorOutput: StringErrorOutput {
    let errorInfo: ErrorDescriptionType
    
    init(_ error: ErrorDescriptionType) {
        self.errorInfo = error
        super.init(nil)
    }
}

enum ErrorDescriptionType {
    case key(String)
    case keyWithPlaceHolder(String, [StringPlaceholder])
}
