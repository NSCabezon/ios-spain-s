import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateCreateNoSepaUsualTransferInputDetailUseCase: UseCase<ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput, ValidateCreateNoSepaUsualTransferInputDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput) throws -> UseCaseResponse<ValidateCreateNoSepaUsualTransferInputDetailUseCaseOkOutput, StringErrorOutput> {
        
        guard let beneficiaryCountryName = requestValues.beneficiaryCountryName, !beneficiaryCountryName.isEmpty else {
            return .error(.destinationToCountryError)
        }
        
        let bankNameValue: String? = requestValues.beneficiaryBankName
        let swiftCodeValue: String? = requestValues.beneficiaryBicSwift?.trim()
        
        switch requestValues.transferType {
        case .identifier:
            guard let bankName = bankNameValue, !bankName.isEmpty else {
                return .error(.nameBankError)
            }
           
        case .bicSwift:
            guard let swiftCode = swiftCodeValue, !swiftCode.isEmpty else {
                return .error(.bicSwiftError)
            }
        }
        
        let noSepaPayeeDTO = NoSepaPayeeDTO(
            swiftCode: swiftCodeValue,
            paymentAccountDescription: requestValues.accountDescription,
            name: requestValues.beneficiaryName,
            town: requestValues.beneficiaryLocality,
            address: requestValues.beneficiaryAddress,
            countryName: beneficiaryCountryName,
            countryCode: requestValues.countryInfo.code,
            bankName: bankNameValue,
            bankAddress: requestValues.beneficiaryBankAddress,
            bankTown: requestValues.beneficiaryBankLocality,
            bankCountryCode: requestValues.countryInfo.code,
            bankCountryName: requestValues.beneficiaryBankCountry)
        
        return .ok(ValidateCreateNoSepaUsualTransferInputDetailUseCaseOkOutput(noSepaPayee: NoSepaPayee.create(noSepaPayeeDTO)))
    }
}

struct ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput {
    let accountDescription: String?
    let beneficiaryName: String?
    let beneficiaryAddress: String?
    let beneficiaryLocality: String?
    let beneficiaryCountryName: String?
    let transferType: NoSepaTransferTypeLocal
    let beneficiaryBicSwift: String?
    let beneficiaryBankName: String?
    let beneficiaryBankAddress: String?
    let beneficiaryBankLocality: String?
    let beneficiaryBankCountry: String?
    let countryInfo: SepaCountryInfo
}

struct ValidateCreateNoSepaUsualTransferInputDetailUseCaseOkOutput {
    let noSepaPayee: NoSepaPayee
}

private extension StringErrorOutput {
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
