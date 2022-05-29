import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class SelectorUsualTransferUseCase: UseCase<SelectorUsualTransferUseCaseInput, SelectorUsualTransferUseCaseOkOutput, SelectorUsualTransferUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: SelectorUsualTransferUseCaseInput) throws -> UseCaseResponse<SelectorUsualTransferUseCaseOkOutput, SelectorUsualTransferUseCaseErrorOutput> {
        guard let stringData = requestValues.amount, !stringData.isEmpty else {
            return UseCaseResponse.error(SelectorUsualTransferUseCaseErrorOutput(.empty))
        }
        guard let dataDecimal = stringData.stringToDecimal else {
            return UseCaseResponse.error(SelectorUsualTransferUseCaseErrorOutput(.invalid))
        }
        guard dataDecimal > 0 else {
            return UseCaseResponse.error(SelectorUsualTransferUseCaseErrorOutput(.zero))
        }
        let amount = Amount.create(value: dataDecimal, currency: requestValues.currencyInfo.currency)
        if requestValues.type == .national {
            return UseCaseResponse.ok(SelectorUsualTransferUseCaseOkOutput(amount: amount, transferNational: nil))
        } else {
            let transferManger = provider.getBsanTransfersManager()
            let typeDTO = getTransferTypeDTO(from: requestValues.type, and: requestValues.subtype)
            let input = UsualTransferInput(amountDTO: amount.amountDTO, concept: requestValues.concept ?? "", beneficiaryMail: "", transferType: typeDTO)
            let response = try transferManger.validateUsualTransfer(originAccountDTO: requestValues.originAccount.accountDTO, usualTransferInput: input, payee: requestValues.favourite.representable)
            guard response.isSuccess(), let data = try response.getResponseData() else {
                let error = try response.getErrorMessage()
                return UseCaseResponse.error(SelectorUsualTransferUseCaseErrorOutput(.service(error: error)))
            }
            guard let transferNationalDTO = data.transferNationalDTO else {
                let error = try response.getErrorMessage()
                return UseCaseResponse.error(SelectorUsualTransferUseCaseErrorOutput(.service(error: error)))
            }
            let transferNational = TransferNational(dto: transferNationalDTO)
            return UseCaseResponse.ok(SelectorUsualTransferUseCaseOkOutput(amount: amount, transferNational: transferNational))
        }
    }
    
    private func getTransferTypeDTO(from type: OnePayTransferType, and subType: OnePayTransferSubType) -> TransferTypeDTO {
        switch type {
        case .national:
            switch subType {
            case .immediate: return .NATIONAL_INSTANT_TRANSFER
            case .urgent: return .NATIONAL_URGENT_TRANSFER
            case .standard: return .NATIONAL_TRANSFER
            }
        case .sepa: return .INTERNATIONAL_SEPA_TRANSFER
        default: return .USUAL_TRANSFER
        }
    }
}

struct SelectorUsualTransferUseCaseInput {
    let amount: String?
    let currencyInfo: SepaCurrencyInfo
    let originAccount: Account
    let subtype: OnePayTransferSubType
    let type: OnePayTransferType
    let concept: String?
    let favourite: Favourite
}

struct SelectorUsualTransferUseCaseOkOutput {
    let amount: Amount
    let transferNational: TransferNational?
}

enum SelectorUsualTransferError {
    case empty
    case zero
    case invalid
    case service(error: String?)
}

class SelectorUsualTransferUseCaseErrorOutput: StringErrorOutput {
    let error: SelectorUsualTransferError
    
    init(_ error: SelectorUsualTransferError) {
        self.error = error
        super.init("")
    }
}
