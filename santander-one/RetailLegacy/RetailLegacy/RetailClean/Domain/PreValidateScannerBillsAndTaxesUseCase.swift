import Foundation
import SANLegacyLibrary
import CoreFoundationLib

enum BillsAndTaxesCodeLength: Int {
    case type507 = 46
    case type502 = 38
    case type521 = 42
    case type508 = 48
}

enum BillsAndTaxesCodeFormat: String {
    case format507 = "90507"
    case format502 = "90502"
    case format521 = "90521"
    case format508 = "90508"
}

class PreValidateScannerBillsAndTaxesUseCase: UseCase<PreValidateScannerBillsAndTaxesUseCaseInput, PreValidateScannerBillsAndTaxesUseCaseOkOutput, PreValidateScannerBillsAndTaxesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PreValidateScannerBillsAndTaxesUseCaseInput) throws -> UseCaseResponse<PreValidateScannerBillsAndTaxesUseCaseOkOutput, PreValidateScannerBillsAndTaxesUseCaseErrorOutput> {
        let barcode = requestValues.code
        let type = requestValues.type
        let originAccount = requestValues.originAccount
        var codeEntityValidated = "", referenceValidated = "", idValidated = "", amountValidated = ""
        
        guard let format = barcode.substring(0, 5) else {
            return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
        }
        
        switch type {
        case .bills:
            //FORMATO 507 (RECIBOS)
            if format == BillsAndTaxesCodeFormat.format507.rawValue {
                guard
                    barcode.count == BillsAndTaxesCodeLength.type507.rawValue,
                    let entityCode = barcode.substring(5, 16),
                    let reference = barcode.substring(16, 29),
                    let id = barcode.substring(29, 35),
                    let amount = barcode.substring(35, 45)
                    else {
                        return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
                }
                codeEntityValidated = entityCode
                referenceValidated = reference
                idValidated = id
                amountValidated = amount
            } else {
                if format == BillsAndTaxesCodeFormat.format502.rawValue || format == BillsAndTaxesCodeFormat.format521.rawValue || format == BillsAndTaxesCodeFormat.format508.rawValue {
                    return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.invalidTypeBills))
                }
                return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
            }
        case .taxes:
            //FORMATO 502 (TRIBUTOS)
            if format == BillsAndTaxesCodeFormat.format502.rawValue {
                guard
                    barcode.count == BillsAndTaxesCodeLength.type502.rawValue,
                    let entityCode = barcode.substring(5, 11),
                    let reference = barcode.substring(11, 23),
                    let id = barcode.substring(23, 30),
                    let amount = barcode.substring(30, 38)
                    else {
                        return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
                }
                codeEntityValidated = entityCode
                referenceValidated = reference
                idValidated = id
                amountValidated = amount
                //FORMATO 521 (TRIBUTOS)
            } else if format == BillsAndTaxesCodeFormat.format521.rawValue {
                guard
                    barcode.count == BillsAndTaxesCodeLength.type521.rawValue,
                    let entityCode = barcode.substring(5, 11),
                    let reference = barcode.substring(11, 23),
                    let id = barcode.substring(23, 33),
                    let amount = barcode.substring(33, 41)
                    else {
                        return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
                }
                codeEntityValidated = entityCode
                referenceValidated = reference
                idValidated = id
                amountValidated = amount
                //FORMATO 508 (TRIBUTOS)
            } else if format == BillsAndTaxesCodeFormat.format508.rawValue {
                guard
                    barcode.count == BillsAndTaxesCodeLength.type508.rawValue,
                    let entityCode = barcode.substring(15, 21),
                    let reference = barcode.substring(21, 33),
                    let id = barcode.substring(33, 40),
                    let amount = barcode.substring(40, 48)
                    else {
                        return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
                }
                codeEntityValidated = entityCode
                referenceValidated = reference
                idValidated = id
                amountValidated = amount
            } else {
                if format == BillsAndTaxesCodeFormat.format507.rawValue {
                    return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.invalidTypeTaxes))
                }
                return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.notValidFormat))
            }
        }
        
        let response = try provider.getBsanBillTaxesManager().validateBillAndTaxes(accountDTO: originAccount.accountDTO, barCode: barcode)
        let errorDescription = try response.getErrorMessage() ?? ""
        guard response.isSuccess(), let paymentBillTaxesDTO = try response.getResponseData() else {
                return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.service, errorDescription))
        }
        guard
            let integerAmount = amountValidated.substring(0, amountValidated.count - 2),
            let decimalAmount = amountValidated.substring(amountValidated.count - 2, amountValidated.count),
            let amountDecimal = (integerAmount + "," + decimalAmount).stringToDecimal
            else {
                return UseCaseResponse.error(PreValidateScannerBillsAndTaxesUseCaseErrorOutput(ValidationBillsAndTaxesCodError.other, errorDescription))
        }
        
        let paymentBillTaxes = PaymentBillTaxes(from: paymentBillTaxesDTO,
                                                originAccount: originAccount,
                                                amount: Amount.createWith(value: amountDecimal),
                                                codeEntity: codeEntityValidated,
                                                reference: referenceValidated,
                                                id: idValidated)
        return UseCaseResponse.ok(PreValidateScannerBillsAndTaxesUseCaseOkOutput(paymentBillTaxes: paymentBillTaxes))
    }
}

struct PreValidateScannerBillsAndTaxesUseCaseInput {
    let code: String
    let type: BillsAndTaxesTypeOperative
    let originAccount: Account
}

struct PreValidateScannerBillsAndTaxesUseCaseOkOutput {
    let paymentBillTaxes: PaymentBillTaxes?
}

enum ValidationBillsAndTaxesCodError {
    case invalidTypeBills
    case invalidTypeTaxes
    case notValidFormat
    case other
    case service
}

protocol ValidationBillsAndTaxesErrorProvider {
    var validationError: ValidationBillsAndTaxesCodError { get }
}

class PreValidateScannerBillsAndTaxesUseCaseErrorOutput: StringErrorOutput, ValidationBillsAndTaxesErrorProvider {
    var validationError: ValidationBillsAndTaxesCodError
    
    init(_ validationError: ValidationBillsAndTaxesCodError, _ errorDesc: String? = "") {
        self.validationError = validationError
        super.init(errorDesc)
    }
}
