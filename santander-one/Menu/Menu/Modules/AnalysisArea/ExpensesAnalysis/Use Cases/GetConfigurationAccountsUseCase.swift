import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetConfigurationAccountsUseCase: UseCase<Void, GetConfigurationAccountsUseCaseOkOutput, StringErrorOutput> {    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetConfigurationAccountsUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetConfigurationAccountsUseCaseOkOutput(accountList: getFakeAccounts()))
    }
    
    func getFakeAccounts() -> [AccountAnalysisInfo] {
        return [
            AccountAnalysisInfo(
                alias: "Cuenta Zero 1|2|3",
                iban: IBANEntity(IBANDTO(countryCode: "ES", checkDigits: "21", codBban: "00000000000000003922")),
                amount: AmountEntity(value: 10150.00, currency: .eur)
            ),
            AccountAnalysisInfo(
                alias: "Mi cuenta personal",
                iban: IBANEntity(IBANDTO(countryCode: "ES", checkDigits: "21", codBban: "00000000000000004059")),
                amount: AmountEntity(value: 4500.98, currency: .eur)
            ),
            AccountAnalysisInfo(
                alias: "Cuenta ING",
                iban: IBANEntity(IBANDTO(countryCode: "ES", checkDigits: "21", codBban: "00000000000000004059")),
                amount: AmountEntity(value: 4500.98, currency: .eur)
            ),
            AccountAnalysisInfo(
                alias: "La del trabajo",
                iban: IBANEntity(IBANDTO(countryCode: "ES", checkDigits: "21", codBban: "00000000000000001234")),
                amount: AmountEntity(value: 1200.23, currency: .eur)
            )
        ]
    }
}

public struct GetConfigurationAccountsUseCaseOkOutput {
    let accountList: [AccountAnalysisInfo]
}
