import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateNoSepaTransferUseCase: UseCase<ValidateNoSepaTransferUseCaseInput, ValidateNoSepaTransferUseCaseOkOutput, ValidateNoSepaTransferUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ValidateNoSepaTransferUseCaseInput) throws -> UseCaseResponse<ValidateNoSepaTransferUseCaseOkOutput, ValidateNoSepaTransferUseCaseErrorOutput> {
        if let beneficiaryEmail = requestValues.beneficiaryEmail, !beneficiaryEmail.isEmpty, !beneficiaryEmail.isValidEmail() {
            return .error(ValidateNoSepaTransferUseCaseErrorOutput(.notValidMail, nil))
        }
        let response = try bsanManagersProvider.getBsanTransfersManager().validationIntNoSEPA(
            noSepaTransferInput: requestValues.toNoSepaTransferInput(beneficiaryAccount: requestValues.beneficiaryAccount, beneficiaryAddress: requestValues.beneficiaryAddress),
            validationSwiftDTO: requestValues.swiftValidation?.dto
        )
        guard response.isSuccess(), let responseData = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage()
            return .error(ValidateNoSepaTransferUseCaseErrorOutput(.service, errorMessage))
        }
        return .ok(ValidateNoSepaTransferUseCaseOkOutput(validation: NoSepaTransferValidation(dto: responseData, transferExpenses: requestValues.expensiveIndicator), beneficiaryEmail: requestValues.beneficiaryEmail))
    }
}

struct ValidateNoSepaTransferUseCaseInput: NoSEPATransferInputConvertible {
    let originAccount: Account
    let beneficiary: String
    let beneficiaryAccount: InternationalAccount
    let beneficiaryAddress: Address?
    let dateOperation: Date?
    let transferAmount: Amount
    let expensiveIndicator: NoSepaTransferExpenses
    let countryCode: String
    let concept: String
    let swiftValidation: SwiftValidation?
    let beneficiaryEmail: String?
}

struct ValidateNoSepaTransferUseCaseOkOutput {
    let validation: NoSepaTransferValidation
    let beneficiaryEmail: String?
}

enum ValidateNoSepaTransferError {
    case service
    case notValidMail
}

class ValidateNoSepaTransferUseCaseErrorOutput: StringErrorOutput {
    let type: ValidateNoSepaTransferError
    
    init(_ type: ValidateNoSepaTransferError, _ errorDesc: String?) {
        self.type = type
        super.init(errorDesc)
    }
}
