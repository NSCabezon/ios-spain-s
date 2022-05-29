import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupPINQueryCardUseCase: SetupUseCase<SetupPINQueryCardUseCaseInput, SetupPINQueryCardUseCaseOkOutput, SetupPINQueryCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupPINQueryCardUseCaseInput) throws -> UseCaseResponse<SetupPINQueryCardUseCaseOkOutput, SetupPINQueryCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDTO = requestValues.card.cardDTO
        let formattedPAN = cardDTO.formattedPAN ?? ""
        
        let cardDetailDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO))
        let cardDataDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardData(formattedPAN))
        let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
        
        let cardDetail = CardDetail.create(cardDetailDTO!, cardDataDTO: cardDataDTO, clientName: globalPositionDTO!.clientName ?? "")
        
        if cardDetail.isCardBeneficiary {
            let cardDetailToken = try provider.getBsanCardsManager().getCardDetailToken(cardDTO: cardDTO, cardTokenType: CardTokenType.panWithoutSpaces)
            
            if cardDetailToken.isSuccess(), let cardDetailTokenDTO = try cardDetailToken.getResponseData() {
                let validatePinQuery = try provider.getBsanCardsManager().validatePIN(cardDTO: cardDTO, cardDetailTokenDTO: cardDetailTokenDTO)
                
                if validatePinQuery.isSuccess(), let signatureWithTokenDTO = try validatePinQuery.getResponseData(), let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) {
                    return UseCaseResponse.ok(SetupPINQueryCardUseCaseOkOutput(operativeConfig: operativeConfig, signatureWithToken: signatureWithToken))
                }
                return UseCaseResponse.error(SetupPINQueryCardUseCaseErrorOutput(try validatePinQuery.getErrorMessage()))
            }
            return UseCaseResponse.error(SetupPINQueryCardUseCaseErrorOutput(try cardDetailToken.getErrorMessage()))
        }
        return UseCaseResponse.error(SetupPINQueryCardUseCaseErrorOutput("ces_alert_beneficiaryCard"))
    }
}

struct SetupPINQueryCardUseCaseInput {
    let card: Card
}

struct SetupPINQueryCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    var signatureWithToken: SignatureWithToken
}

extension SetupPINQueryCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupPINQueryCardUseCaseErrorOutput: StringErrorOutput {
}
