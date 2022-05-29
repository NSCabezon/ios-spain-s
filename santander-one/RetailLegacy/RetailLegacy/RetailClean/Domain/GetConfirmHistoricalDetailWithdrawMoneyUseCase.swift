import CoreFoundationLib
import SANLegacyLibrary

class GetConfirmHistoricalDetailWithdrawMoneyUseCase: UseCase<GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput, GetConfirmHistoricalDetailWithdrawMoneyUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput) throws -> UseCaseResponse<GetConfirmHistoricalDetailWithdrawMoneyUseCaseOkOutput, StringErrorOutput> {
        
        let cardDTO = requestValues.card.cardDTO
        let cardDetail: CardDetail
        
        if let detail = requestValues.cardDetail {
            cardDetail = detail
            
        } else {
            let cardDetailResponse = try provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO)
            
            guard cardDetailResponse.isSuccess(), let cardDetailDTO = try cardDetailResponse.getResponseData() else {
                return UseCaseResponse.error(StringErrorOutput(try cardDetailResponse.getErrorMessage()))
            }
            
            let cardData: CardDataDTO?
            if let pan = cardDTO.formattedPAN, let responseCardData = try? provider.getBsanCardsManager().getCardData(pan), responseCardData.isSuccess(), let cardDataResponse = try? responseCardData.getResponseData() {
                cardData = cardDataResponse
            } else {
                cardData = nil
            }
            
            let clientName = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())?.clientName ?? ""
            
            cardDetail = CardDetail.create(cardDetailDTO, cardDataDTO: cardData, clientName: clientName)
        }
        
        let accountResponse = try provider.getBsanAccountsManager().getAccount(fromOldContract: cardDetail.cardDetailDTO?.linkedAccountOldContract)
        guard accountResponse.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(try accountResponse.getErrorMessage()))
        }
        let accountDTO = try accountResponse.getResponseData()
        let account: Account? = accountDTO.map({ Account(dto: $0) })
        
        return UseCaseResponse.ok(GetConfirmHistoricalDetailWithdrawMoneyUseCaseOkOutput(cardDetail: cardDetail, account: account))
        
    }
}

struct GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput {
    let card: Card
    let cardDetail: CardDetail?
    let dispensation: Dispensation
}

struct GetConfirmHistoricalDetailWithdrawMoneyUseCaseOkOutput {
    let cardDetail: CardDetail
    let account: Account?
}
