import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SetupCardModifyPaymentFormUseCase: SetupUseCase<SetupCardModifyPaymentFormUseCaseInput, SetupCardModifyPaymentFormUseCaseOkOutput, SetupCardModifyPaymentFormUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupCardModifyPaymentFormUseCaseInput) throws -> UseCaseResponse<SetupCardModifyPaymentFormUseCaseOkOutput, SetupCardModifyPaymentFormUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDTO = requestValues.card.cardDTO
        
        // CardDetail
        let responseDetailCard = try provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO)
        guard responseDetailCard.isSuccess(), let cardDetailDTO = try responseDetailCard.getResponseData() else {
            return .error(SetupCardModifyPaymentFormUseCaseErrorOutput(try responseDetailCard.getErrorMessage()))
        }
        let clientName = try? checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())?.clientName ?? ""
        let cardDataDTO: CardDataDTO?        
        if let pan = cardDTO.formattedPAN, let responseCardData = try? provider.getBsanCardsManager().getCardData(pan), responseCardData.isSuccess(), let cardDataResponse = try? responseCardData.getResponseData() {
            cardDataDTO = cardDataResponse
        } else {
            cardDataDTO = nil
        }
        let cardDetail = CardDetail.create(cardDetailDTO, cardDataDTO: cardDataDTO, clientName: clientName ?? "")
        
        let response = try provider.getBsanCardsManager().getPaymentChange(cardDTO: cardDTO)
        guard response.isSuccess(), let changePaymentDTO = try response.getResponseData() else {
            return .error(SetupCardModifyPaymentFormUseCaseErrorOutput(try response.getErrorMessage()))
        }
        return .ok(SetupCardModifyPaymentFormUseCaseOkOutput(operativeConfig: operativeConfig, cardDetail: cardDetail, changePayment: ChangePayment(changePaymentDTO)))
    }
}

struct SetupCardModifyPaymentFormUseCaseInput {
    let card: Card
}
struct SetupCardModifyPaymentFormUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    var cardDetail: CardDetail
    let changePayment: ChangePayment
}

class SetupCardModifyPaymentFormUseCaseErrorOutput: StringErrorOutput {}
