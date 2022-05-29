import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateChargeDischargeUseCase: UseCase<ValidateChargeDischargeUseCaseInput, ValidateChargeDischargeUseCaseOkOutput, ValidateChargeDischargeUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateChargeDischargeUseCaseInput) throws -> UseCaseResponse<ValidateChargeDischargeUseCaseOkOutput, ValidateChargeDischargeUseCaseErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let accountDTO = requestValues.account.accountDTO
        let prepaidCardDataDTO = requestValues.prepaidCardData.dto

        let loadPrepaidCardDataResponse = try provider.getBsanCardsManager().loadPrepaidCardData(cardDTO: cardDTO)
        guard loadPrepaidCardDataResponse.isSuccess() else {
            return UseCaseResponse.error(ValidateChargeDischargeUseCaseErrorOutput(try loadPrepaidCardDataResponse.getErrorCode()))
        }
        
        switch requestValues.inputType {
        case .charge(let value):
            let amountDto = AmountDTO(value: Decimal(Double(value.replace(".", "").replace(",", "."))!), currency: CurrencyDTO.create("EUR"))
            
            let response = try provider.getBsanCardsManager().validateLoadPrepaidCard(cardDTO: cardDTO, amountDTO: amountDto, accountDTO: accountDTO, prepaidCardDataDTO: prepaidCardDataDTO)
            
            if response.isSuccess(),
                let validateLoadPrepaidCard = try response.getResponseData(),
                let preliq = validateLoadPrepaidCard.preliqDataDTO,
                let token = validateLoadPrepaidCard.token,
                let signature = prepaidCardDataDTO.signatureDTO {
                return UseCaseResponse.ok(ValidateChargeDischargeUseCaseOkOutput(signature: Signature(dto: signature), validatePrepaidCard: ValidatePrepaidCard(dto: validateLoadPrepaidCard, preliqData: PreliqData(dto: preliq), token: token)))
            }
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(ValidateChargeDischargeUseCaseErrorOutput(error))
        case .discharge(let value):
            let amountDto = AmountDTO(value: Decimal(Double(value.replace(".", "").replace(",", "."))!), currency: CurrencyDTO.create("EUR"))
            
            let response = try provider.getBsanCardsManager().validateUnloadPrepaidCard(cardDTO: cardDTO, amountDTO: amountDto, accountDTO: accountDTO, prepaidCardDataDTO: prepaidCardDataDTO)
            
            if response.isSuccess(),
                let validateUnloadPrepaidCard = try response.getResponseData(),
                let preliq = validateUnloadPrepaidCard.preliqDataDTO,
                let token = validateUnloadPrepaidCard.token,
                let signature = prepaidCardDataDTO.signatureDTO {
                return UseCaseResponse.ok(ValidateChargeDischargeUseCaseOkOutput(signature: Signature(dto: signature), validatePrepaidCard: ValidatePrepaidCard(dto: validateUnloadPrepaidCard, preliqData: PreliqData(dto: preliq), token: token)))
            }
        }
        return UseCaseResponse.ok()
    }
}

struct ValidateChargeDischargeUseCaseInput {
    let inputType: ChargeDischargeType
    let card: Card
    let account: Account
    let prepaidCardData: PrepaidCardData
}

struct ValidateChargeDischargeUseCaseOkOutput {
    let signature: Signature
    let validatePrepaidCard: ValidatePrepaidCard
}

class ValidateChargeDischargeUseCaseErrorOutput: StringErrorOutput {}
