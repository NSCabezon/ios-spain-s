import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ModifyPeriodicTransferDestinationUseCase: UseCase<ModifyPeriodicTransferDestinationUseCaseInput, ModifyPeriodicTransferDestinationUseCaseOkOutput, StringErrorOutput> {
    
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
    
    override func executeUseCase(requestValues: ModifyPeriodicTransferDestinationUseCaseInput) throws -> UseCaseResponse<ModifyPeriodicTransferDestinationUseCaseOkOutput, StringErrorOutput> {
        let strategy: TransferStrategy
        switch requestValues.country.code {
        case "ES":
            strategy = NationalTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        default:
            strategy = SepaTransferStrategy(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
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
            let modifiedData = ModifiedPeriodicTransfer(
                iban: iban,
                amount: amount,
                concept: requestValues.concept,
                periodicity: requestValues.periodicity,
                startDate: requestValues.startDate,
                endDate: requestValues.endDate,
                workingDayIssue: requestValues.workingDayIssue
            )
            return .ok(ModifyPeriodicTransferDestinationUseCaseOkOutput(modifiedData: modifiedData))
        case .error:
            return .error(StringErrorOutput("onePay_alert_valueIban"))
        }
    }
}

struct ModifyPeriodicTransferDestinationUseCaseInput: IBANValidable {
    let iban: String?
    let amount: String
    let concept: String?
    let periodicity: OnePayTransferPeriodicity
    let startDate: Date
    let endDate: OnePayTransferTimeEndDate
    let workingDayIssue: OnePayTransferWorkingDayIssue
    let country: SepaCountryInfo
    let currency: SepaCurrencyInfo
}

struct ModifyPeriodicTransferDestinationUseCaseOkOutput {
    let modifiedData: ModifiedPeriodicTransfer
}
