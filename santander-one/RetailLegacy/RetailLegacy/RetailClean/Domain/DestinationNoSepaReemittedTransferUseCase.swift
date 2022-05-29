import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class DestinationNoSepaReemittedTransferUseCase: UseCase<DestinationNoSepaReemittedTransferUseCaseInput, DestinationNoSepaReemittedTransferUseCaseOkOutput, DestinationNoSepaReemittedTransferUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: DestinationNoSepaReemittedTransferUseCaseInput) throws -> UseCaseResponse<DestinationNoSepaReemittedTransferUseCaseOkOutput, DestinationNoSepaReemittedTransferUseCaseErrorOutput> {
        guard let stringData = requestValues.amount, !stringData.isEmpty else {
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.amount, nil))
        }
        guard let dataDecimal = stringData.stringToDecimal else {
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.amount, nil))
        }
        guard dataDecimal > 0 else {
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.zero, nil))
        }
        let oldAmount = requestValues.transferDetail.transferAmount
        guard let amount = Amount.createWith(value: dataDecimal, amount: oldAmount) else {
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.service, nil))
        }
        switch requestValues.type {
        case .bicSwift?:
            return try executeNoSepaCase(requestValues: requestValues, amount: amount, type: .bicSwift)
        case .identifier?:
            return try executeNoSepaCase(requestValues: requestValues, amount: amount, type: .identifier)
        case .none:
            return try executeSepaCase(requestValues: requestValues, amount: amount)
        }
    }
    
    private func executeNoSepaCase(requestValues: DestinationNoSepaReemittedTransferUseCaseInput, amount: Amount, type: NoSepaTransferTypeLocal) throws -> UseCaseResponse<DestinationNoSepaReemittedTransferUseCaseOkOutput, DestinationNoSepaReemittedTransferUseCaseErrorOutput> {
        let beneficiaryAccount: InternationalAccount
        let transferType: NoSepaTransferType
        switch type {
        case .identifier:
            guard let accountName = requestValues.bankName, !accountName.isEmpty else {
                return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.nameBankError, nil))
            }
            beneficiaryAccount = InternationalAccount(
                bankData: BankData(name: accountName,
                                   address: requestValues.bankAddress,
                                   locality: requestValues.bankCity,
                                   country: requestValues.bankCountry),
                account: requestValues.transferDetail.payee?.paymentAccountDescription ?? ""
            )
            transferType = .identifier(name: accountName, address: requestValues.bankAddress, locality: requestValues.bankCity, country: requestValues.bankCountry)
        case .bicSwift:
            guard let swift = requestValues.bankBicSwift?.trim().uppercased(), !swift.isEmpty else {
                return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.bicSwiftError, nil))
            }
            beneficiaryAccount = InternationalAccount(
                swift: swift,
                account: requestValues.transferDetail.payee?.paymentAccountDescription ?? ""
            )
            transferType = .bicSwift(identifier: swift)
        }
        let noSepaTransferInput = NoSEPATransferInput(
            originAccountDTO: requestValues.originAccount.accountDTO,
            beneficiary: requestValues.transferDetail.payee?.name ?? "",
            beneficiaryAccount: beneficiaryAccount.dto,
            beneficiaryAddress: AddressDTO(country: requestValues.transferDetail.countryName ?? "", address: requestValues.transferDetail.payee?.address, locality: requestValues.transferDetail.payee?.town),
            indicatorResidence: false,
            dateOperation: DateModel(date: Date()),
            transferAmount: amount.amountDTO,
            expensiveIndicator: requestValues.expenses.dto,
            type: .INTERNATIONAL_NO_SEPA_TRANSFER,
            countryCode: requestValues.transferDetail.destinationCountryCode ?? "",
            concept: requestValues.concept ?? "",
            beneficiaryEmail: nil
        )
        let validateSwiftResponse = try bsanManagersProvider.getBsanTransfersManager().validateSwift(noSepaTransferInput: noSepaTransferInput)
        guard validateSwiftResponse.isSuccess(), var swiftValidation: ValidationSwiftDTO = try validateSwiftResponse.getResponseData() else {
            let error = try validateSwiftResponse.getErrorMessage()
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.service, error))
        }
        if type == .identifier {
            swiftValidation.beneficiaryBic = nil
        }
        let response = try bsanManagersProvider.getBsanTransfersManager().validationIntNoSEPA(noSepaTransferInput: noSepaTransferInput, validationSwiftDTO: swiftValidation)
        guard response.isSuccess(), let noSepaTransferValidation = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.service, error))
        }
        return .ok(DestinationNoSepaReemittedTransferUseCaseOkOutput(swiftValidation: SwiftValidation(dto: swiftValidation), transferType: transferType, noSepaTransferValidation: NoSepaTransferValidation(dto: noSepaTransferValidation, transferExpenses: requestValues.expenses), amount: amount, beneficiaryAccount: beneficiaryAccount))
    }
    
    private func executeSepaCase(requestValues: DestinationNoSepaReemittedTransferUseCaseInput, amount: Amount) throws -> UseCaseResponse<DestinationNoSepaReemittedTransferUseCaseOkOutput, DestinationNoSepaReemittedTransferUseCaseErrorOutput> {
        let beneficiaryAccount = InternationalAccount(account: requestValues.transferDetail.payee?.paymentAccountDescription ?? "")
        let noSepaTransferInput = NoSEPATransferInput(
            originAccountDTO: requestValues.originAccount.accountDTO,
            beneficiary: requestValues.transferDetail.payee?.name ?? "",
            beneficiaryAccount: beneficiaryAccount.dto,
            beneficiaryAddress: AddressDTO(country: requestValues.transferDetail.countryName ?? "", address: requestValues.transferDetail.payee?.address, locality: requestValues.transferDetail.payee?.town),
            indicatorResidence: false,
            dateOperation: DateModel(date: Date()),
            transferAmount: amount.amountDTO,
            expensiveIndicator: requestValues.expenses.dto,
            type: .INTERNATIONAL_NO_SEPA_TRANSFER,
            countryCode: requestValues.transferDetail.destinationCountryCode ?? "",
            concept: requestValues.transferDetail.concept1 ?? "",
            beneficiaryEmail: nil
        )
        let response = try bsanManagersProvider.getBsanTransfersManager().validationIntNoSEPA(noSepaTransferInput: noSepaTransferInput, validationSwiftDTO: ValidationSwiftDTO())
        
        guard response.isSuccess(), let validation = try response.getResponseData() else {
            return .error(DestinationNoSepaReemittedTransferUseCaseErrorOutput(.service, try response.getErrorMessage()))
        }
        return .ok(DestinationNoSepaReemittedTransferUseCaseOkOutput(swiftValidation: SwiftValidation(dto: ValidationSwiftDTO()), transferType: .sepa, noSepaTransferValidation: NoSepaTransferValidation(dto: validation, transferExpenses: requestValues.expenses), amount: amount, beneficiaryAccount: beneficiaryAccount))
    }
}

struct DestinationNoSepaReemittedTransferUseCaseInput {
    let expenses: NoSepaTransferExpenses
    let type: NoSepaTransferTypeLocal?
    let amount: String?
    let bankName: String?
    let bankAddress: String?
    let bankCity: String?
    let bankCountry: String?
    let bankBicSwift: String?
    let originAccount: Account
    let transferDetail: BaseNoSepaPayeeDetailProtocol
    let concept: String?
}

struct DestinationNoSepaReemittedTransferUseCaseOkOutput {
    let swiftValidation: SwiftValidation
    let transferType: NoSepaTransferType
    let noSepaTransferValidation: NoSepaTransferValidation
    let amount: Amount
    let beneficiaryAccount: InternationalAccount
}

enum DestinationNoSepaReemittedTransferError {
    case service
    case amount
    case zero
    case nameBankError
    case bicSwiftError
}

class DestinationNoSepaReemittedTransferUseCaseErrorOutput: StringErrorOutput {
    let type: DestinationNoSepaReemittedTransferError
    
    init(_ type: DestinationNoSepaReemittedTransferError, _ errorDesc: String?) {
        self.type = type
        super.init(errorDesc)
    }
}
