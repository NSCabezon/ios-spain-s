import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateUsualTransferUseCase: UseCase<ValidateUsualTransferUseCaseInput, ValidateUsualTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateUsualTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        switch requestValues.type {
        case .sepa, .national:
            return try validateNationalAndSepaTransfer(requestValues: requestValues)
        case .noSepa:
            fatalError()
        }
    }
    
    private func validateNationalAndSepaTransfer(requestValues: ValidateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateUsualTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail, !beneficiaryMail.isEmpty, !beneficiaryMail.isValidEmail() {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let transferManger = provider.getBsanTransfersManager()
        let typeDTO = getTransferTypeDTO(from: requestValues.type, and: requestValues.subType)
        let input = UsualTransferInput(amountDTO: requestValues.amount.amountDTO, concept: requestValues.concept ?? "", beneficiaryMail: requestValues.beneficiaryMail ?? "", transferType: typeDTO)
        let response = try transferManger.validateUsualTransfer(originAccountDTO: requestValues.originAccount.accountDTO, usualTransferInput: input, payee: requestValues.favourite.representable)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDescription)))
        }
        guard let transferNationalDTO = data.transferNationalDTO else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        guard let scaRepresentable = transferNationalDTO.scaRepresentable else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let transferNational = TransferNational(dto: transferNationalDTO)
        let scaEntity = LegacySCAEntity(scaRepresentable)
        return UseCaseResponse.ok(ValidateUsualTransferUseCaseOkOutput(transferNational: transferNational, beneficiaryMail: requestValues.beneficiaryMail, scaEntity: scaEntity))
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

struct ValidateUsualTransferUseCaseInput {
    let originAccount: Account
    let favourite: Favourite
    let beneficiaryMail: String?
    let amount: Amount
    let concept: String?
    let type: OnePayTransferType
    let subType: OnePayTransferSubType
}

struct ValidateUsualTransferUseCaseOkOutput {
    let transferNational: TransferNational
    let beneficiaryMail: String?
    let scaEntity: LegacySCAEntity
}

extension ValidateUsualTransferUseCaseOkOutput: ValidateTransferUseCaseOkOutput {}
