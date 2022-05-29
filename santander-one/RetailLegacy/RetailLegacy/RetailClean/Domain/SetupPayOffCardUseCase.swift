import SANLegacyLibrary
import CoreFoundationLib

final class SetupPayOffCardUseCase: SetupUseCase<SetupPayOffCardUseCaseInput, SetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupPayOffCardUseCaseInput) throws -> UseCaseResponse<SetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDTO = requestValues.card.cardDTO
        let cardDetailDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO))
        let accountDTO = try checkRepositoryResponse(provider.getBsanAccountsManager().getAccount(fromOldContract: cardDetailDTO?.linkedAccountOldContract))
        let cardDataDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardData(cardDTO.formattedPAN!))
        let globalPosition = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
        let cardDetail = CardDetail.create(cardDetailDTO!, cardDataDTO: cardDataDTO, clientName: globalPosition?.clientName ?? "")
        guard let account = accountDTO else {
            return .ok(SetupPayOffCardUseCaseOkOutput(operativeConfig: operativeConfig, cardDetail: cardDetail, account: nil))
        }
        return .ok(SetupPayOffCardUseCaseOkOutput(operativeConfig: operativeConfig, cardDetail: cardDetail, account: Account.create(account)))
    }
}

struct SetupPayOffCardUseCaseInput {
    let card: Card
}

struct SetupPayOffCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    var cardDetail: CardDetail
    var account: Account?
}
