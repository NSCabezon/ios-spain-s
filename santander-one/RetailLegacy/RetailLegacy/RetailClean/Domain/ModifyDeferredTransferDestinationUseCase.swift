import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ModifyDeferredTransferDestinationUseCase: UseCase<ModifyDeferredTransferDestinationUseCaseInput, ModifyDeferredTransferDestinationUseCaseOkOutput, StringErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ModifyDeferredTransferDestinationUseCaseInput) throws -> UseCaseResponse<ModifyDeferredTransferDestinationUseCaseOkOutput, StringErrorOutput> {
        let strategy: TransferStrategy
        switch requestValues.country.code {
        case "ES":
            strategy = NationalTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        default:
            strategy = SepaTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
        }
        guard let dataDecimal = requestValues.amount.stringToDecimal else {
            return .error(StringErrorOutput("sendMoney_alert_amountTransfer"))
        }
        guard dataDecimal > 0 else {
            return .error(StringErrorOutput("sendMoney_alert_higherValue"))
        }
        let amount = Amount.create(value: dataDecimal, currency: requestValues.currency.currency)
        switch strategy.ibanValidation(requestValues: requestValues) {
        case .ok(let iban):
            let modifiedData = ModifiedDeferredTransfer(iban: iban, amount: amount, concept: requestValues.concept, date: requestValues.date)
            return .ok(ModifyDeferredTransferDestinationUseCaseOkOutput(modifiedData: modifiedData))
        case .error:
            return .error(StringErrorOutput("onePay_alert_valueIban"))
        }
    }
}

struct ModifyDeferredTransferDestinationUseCaseInput: IBANValidable {
    let iban: String?
    let amount: String
    let concept: String?
    let date: Date
    let country: SepaCountryInfo
    let currency: SepaCurrencyInfo
}

struct ModifyDeferredTransferDestinationUseCaseOkOutput {
    let modifiedData: ModifiedDeferredTransfer
}
