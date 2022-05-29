import CoreFoundationLib
import CoreDomain

public protocol IbanValidationSendMoneyUseCaseProtocol: UseCase<IbanValidationSendMoneyUseCaseInput, IbanValidationSendMoneyUseCaseOkOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {}

public struct IbanValidationSendMoneyUseCaseInput {
    public let iban: IBANRepresentable?
    public let name: String?
    public let alias: String?
    public let saveFavorites: Bool
    public let favouriteList: [PayeeRepresentable]
}

public enum IbanValidationSendMoneyUseCaseOkOutput {
    case empty
    case data(Any)
}
