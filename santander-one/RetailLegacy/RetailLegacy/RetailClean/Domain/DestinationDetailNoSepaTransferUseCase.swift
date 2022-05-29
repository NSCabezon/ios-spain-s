import CoreDomain
import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol NoSEPATransferInputConvertible {
    var originAccount: Account { get }
    var beneficiary: String { get }
    var dateOperation: Date? { get }
    var transferAmount: Amount { get }
    var expensiveIndicator: NoSepaTransferExpenses { get }
    var countryCode: String { get }
    var concept: String { get }
    var beneficiaryEmail: String? { get }
}

extension NoSEPATransferInputConvertible {
    
    var beneficiaryEmail: String? {
        return nil
    }
    
    func toNoSepaTransferInput(beneficiaryAccount: InternationalAccount, beneficiaryAddress: Address?) -> NoSEPATransferInput {
        return NoSEPATransferInput(
            originAccountDTO: originAccount.accountDTO,
            beneficiary: beneficiary,
            beneficiaryAccount: beneficiaryAccount.dto,
            beneficiaryAddress: beneficiaryAddress?.dto,
            indicatorResidence: false,
            dateOperation: dateOperation.map({ DateModel(date: $0) }),
            transferAmount: transferAmount.amountDTO,
            expensiveIndicator: expensiveIndicator.dto,
            type: .INTERNATIONAL_NO_SEPA_TRANSFER,
            countryCode: countryCode,
            concept: concept,
            beneficiaryEmail: beneficiaryEmail
        )
    }
}

class DestinationDetailNoSepaTransferUseCase: UseCase<DestinationDetailNoSepaTransferUseCaseInput, DestinationDetailNoSepaTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: DestinationDetailNoSepaTransferUseCaseInput) throws -> UseCaseResponse<DestinationDetailNoSepaTransferUseCaseOkOutput, StringErrorOutput> {
        
        guard !requestValues.beneficiary.isEmpty else {
            return .error(.nameRecipientsError)
        }
        
        guard let beneficiaryAccountValue = requestValues.beneficiaryAccountValue, !beneficiaryAccountValue.isEmpty else {
            return .error(.destinationAccountsError)
        }
        
        guard let beneficiaryCountry = requestValues.beneficiaryCountry, !beneficiaryCountry.isEmpty else {
            return .error(.destinationToCountryError)
        }
        let address = Address(country: beneficiaryCountry, address: requestValues.beneficiaryAddress, locality: requestValues.beneficiaryLocality)
        let beneficiaryAccount: InternationalAccount
        let transferType: NoSepaTransferType
        switch requestValues.transferType {
        case .identifier:
            guard let accountName = requestValues.beneficiaryAccountName, !accountName.isEmpty else {
                return .error(.nameBankError)
            }
            beneficiaryAccount = InternationalAccount(
                bankData: BankData(name: accountName,
                                   address: requestValues.beneficiaryAccountAddress,
                                   locality: requestValues.beneficiaryAccountLocality,
                                   country: requestValues.beneficiaryAccountCountry),
                account: beneficiaryAccountValue
            )
            transferType = .identifier(name: accountName, address: requestValues.beneficiaryAccountAddress, locality: requestValues.beneficiaryAccountLocality, country: requestValues.beneficiaryAccountCountry)
        case .bicSwift:
            guard let swift = requestValues.beneficiaryAccountBicSwift?.trim(), !swift.isEmpty else {
                return .error(.bicSwiftError)
            }
            beneficiaryAccount = InternationalAccount(
                swift: swift,
                account: beneficiaryAccountValue
            )
            transferType = .bicSwift(identifier: swift)
        }
        let noSepaTransferInput = requestValues.toNoSepaTransferInput(beneficiaryAccount: beneficiaryAccount, beneficiaryAddress: address)
        let validateSwiftResponse = try bsanManagersProvider.getBsanTransfersManager().validateSwift(noSepaTransferInput: noSepaTransferInput)
        guard validateSwiftResponse.isSuccess(), let swiftValidation = try validateSwiftResponse.getResponseData() else {
            let error = try validateSwiftResponse.getErrorMessage()
            return .error(StringErrorOutput(error))
        }
        
        let response = try bsanManagersProvider.getBsanTransfersManager().validationIntNoSEPA(noSepaTransferInput: noSepaTransferInput, validationSwiftDTO: swiftValidation)
        guard response.isSuccess(), let noSepaTransferValidation = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return .error(StringErrorOutput(error))
        }
        return .ok(DestinationDetailNoSepaTransferUseCaseOkOutput(swiftValidation: SwiftValidation(dto: swiftValidation), transferType: transferType, beneficiaryAddress: address, beneficiary: requestValues.beneficiary, noSepaTransferValidation: NoSepaTransferValidation(dto: noSepaTransferValidation, transferExpenses: requestValues.expensiveIndicator)))
    }
}

struct DestinationDetailNoSepaTransferUseCaseInput: NoSEPATransferInputConvertible {
    let originAccount: Account
    let beneficiary: String
    let countryInfo: SepaCountryInfo
    let beneficiaryAccountValue: String?
    let beneficiaryAccountName: String?
    let beneficiaryAccountAddress: String?
    let beneficiaryAccountLocality: String?
    let beneficiaryAccountCountry: String?
    let beneficiaryAccountBicSwift: String?
    let beneficiaryCountry: String?
    let beneficiaryAddress: String?
    let beneficiaryLocality: String?
    let dateOperation: Date?
    let transferAmount: Amount
    let expensiveIndicator: NoSepaTransferExpenses
    let countryCode: String
    let concept: String
    let transferType: NoSepaTransferTypeLocal
}

struct DestinationDetailNoSepaTransferUseCaseOkOutput {
    let swiftValidation: SwiftValidation
    let transferType: NoSepaTransferType
    let beneficiaryAddress: Address
    let beneficiary: String
    let noSepaTransferValidation: NoSepaTransferValidation
}

private extension StringErrorOutput {
    static var destinationAccountsError: StringErrorOutput {
        return StringErrorOutput("onePay_alert_destinationAccounts")
    }
    static var nameRecipientsError: StringErrorOutput {
        return StringErrorOutput("onePay_alert_nameRecipients")
    }
    static var destinationToCountryError: StringErrorOutput {
        return StringErrorOutput("onePay_alert_destinationToCountry")
    }
    static var nameBankError: StringErrorOutput {
        return StringErrorOutput("onePay_alert_nameBank")
    }
    static var bicSwiftError: StringErrorOutput {
        return StringErrorOutput("onePay_alert_bicSwift")
    }
}
