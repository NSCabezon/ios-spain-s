import SANLegacyLibrary
import CoreFoundationLib

class SetupWithdrawMoneyWithCodeUseCase: SetupUseCase<SetupWithdrawMoneyWithCodeUseCaseInput, SetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let keyCashWithdrawalAmounts = "cashWithdrawalAmounts"

    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }

    override func executeUseCase(requestValues: SetupWithdrawMoneyWithCodeUseCaseInput) throws -> UseCaseResponse<SetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cashWithdrawalAmounts = appConfigRepository.getAppConfigListNode(keyCashWithdrawalAmounts)

        let cardDTO = requestValues.card.cardDTO
        guard let cardDetailDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO)) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }

        let cardDataDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardData(cardDTO.formattedPAN!))
        let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
        let cardDetail = CardDetail.create(cardDetailDTO, cardDataDTO: cardDataDTO, clientName: globalPositionDTO?.clientName ?? "")
        return UseCaseResponse.ok(SetupWithdrawMoneyWithCodeUseCaseOkOutput(amounts: cashWithdrawalAmounts, cardDetail: cardDetail, operativeConfig: operativeConfig))
    }
}

struct SetupWithdrawMoneyWithCodeUseCaseInput {
    let card: Card
}

struct SetupWithdrawMoneyWithCodeUseCaseOkOutput {
    let amounts: [String]?
    let cardDetail: CardDetail
    var operativeConfig: OperativeConfig
}

extension SetupWithdrawMoneyWithCodeUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
}
