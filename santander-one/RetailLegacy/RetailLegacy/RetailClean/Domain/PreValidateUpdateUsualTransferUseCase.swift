import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class PreValidateUpdateUsualTransferUseCase: UseCase<PreValidateUpdateUsualTransferUseCaseInput, PreValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreValidateUpdateUsualTransferUseCaseInput) throws -> UseCaseResponse<PreValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        guard
            let ibanString = requestValues.iban
            else {
                return .error(StringErrorOutput("onePay_alert_valueIban"))
        }
        
        let strategy: TransferStrategy
        switch requestValues.country.code {
        case "ES":
            strategy = NationalTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        default:
            strategy = SepaTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        }
     
        switch strategy.ibanValidation(requestValues: requestValues) {
        case .ok(let iban):
            guard bankingUtils.isValidIban(ibanString: ibanString) else {
                return .error(StringErrorOutput("onePay_alert_valueIban"))
            }
            return .ok(PreValidateUpdateUsualTransferUseCaseOkOutput(iban: iban))
        case .error:
            return .error(StringErrorOutput("onePay_alert_valueIban"))
        }
    }
}

struct PreValidateUpdateUsualTransferUseCaseInput: IBANValidable {
    let iban: String?
    let country: SepaCountryInfo
}

struct PreValidateUpdateUsualTransferUseCaseOkOutput {
    let iban: IBAN
}
