import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupPayLaterCardUseCase: SetupUseCase<SetupPayLaterCardUseCaseInput, SetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupPayLaterCardUseCaseInput) throws -> UseCaseResponse<SetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        guard let card = requestValues.card else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let cardDTO = card.cardDTO
        let cardManager = provider.getBsanCardsManager()
        let responseDetailCard = try cardManager.getCardDetail(cardDTO: cardDTO)
        
        guard responseDetailCard.isSuccess(), let cardDetailDTO = try responseDetailCard.getResponseData() else {
            let error = try responseDetailCard.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        
        let clientName = try? checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())?.clientName ?? ""
        let cardDataDTO: CardDataDTO?
        
        if let pan = cardDTO.formattedPAN, let responseCardData = try? cardManager.getCardData(pan), responseCardData.isSuccess(), let cardDataResponse = try? responseCardData.getResponseData() {
            cardDataDTO = cardDataResponse
        } else {
            cardDataDTO = nil
        }
        
        let cardDetail = CardDetail.create(cardDetailDTO, cardDataDTO: cardDataDTO, clientName: clientName ?? "")
        let getPayLaterDataDTO = try cardManager.getPayLaterData(cardDTO: cardDTO)
        
        guard getPayLaterDataDTO.isSuccess(), let payLaterDTO = try getPayLaterDataDTO.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try getPayLaterDataDTO.getErrorMessage()))
        }        
        return UseCaseResponse.ok(SetupPayLaterCardUseCaseOkOutput(operativeConfig: operativeConfig, card: card, cardDetail: cardDetail, percentageAmount: calculateMinimumAmountPercent(card: card), payLater: PayLater(dto: payLaterDTO)))
    }
    
    func calculateMinimumAmountPercent(card: Card) -> Amount {
        guard let decimalAmount = card.getAmount()?.value else { return Amount.zero() }
        let threePercentOfTotalAmount = ((0.03 * abs(decimalAmount)) + 0.01)
        let roundedPercent = threePercentOfTotalAmount.getFormattedDescriptionValue(2)
        let defaultValue: Decimal = 25
        let value = Decimal(string: roundedPercent.replace(".", "").replace(",", "."))
        
        guard var finalValue = value else { return .zero() }
        
        if finalValue.isLess(than: defaultValue) {
            finalValue = defaultValue
        }
        
        return Amount.createWith(value: finalValue)
    }
}

struct SetupPayLaterCardUseCaseInput {
    let card: Card?
}

struct SetupPayLaterCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let card: Card
    let cardDetail: CardDetail
    let percentageAmount: Amount
    let payLater: PayLater
}

extension SetupPayLaterCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}
