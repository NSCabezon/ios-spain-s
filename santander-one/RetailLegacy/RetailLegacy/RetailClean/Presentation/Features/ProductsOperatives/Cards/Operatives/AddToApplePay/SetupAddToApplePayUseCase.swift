import SANLegacyLibrary
import CoreFoundationLib

class SetupAddToApplePayUseCase: SetupUseCase<SetupAddToApplePayUseCaseInput, SetupAddToApplePayUseCaseOKOutput, StringErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupAddToApplePayUseCaseInput) throws -> UseCaseResponse<SetupAddToApplePayUseCaseOKOutput, StringErrorOutput> {
        guard let card = requestValues.card else {
            return .error(StringErrorOutput("generic_alert_errorCard"))
        }
        
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDetailResponse = try self.bsanManagersProvider.getBsanCardsManager().getCardDetail(cardDTO: card.cardDTO)
        
        let signatureResponse = try self.bsanManagersProvider.getBsanSignatureManager().requestApplePaySignaturePositions()
        let cmp = try self.bsanManagersProvider.getBsanSendMoneyManager().loadCMPSStatus()
        
        guard
            cmp.isSuccess(),
            let otpExceptedInd = try cmp.getResponseData()?.otpExceptedInd,
            otpExceptedInd == false
        else {
            return .error(StringErrorOutput("wallet_alert_rememberOTP"))
        }
        
        guard
            cardDetailResponse.isSuccess(),
            signatureResponse.isSuccess(),
            let signature = try signatureResponse.getResponseData(),
            let signatureWithToken = SignatureWithToken(dto: signature),
            let detail = try cardDetailResponse.getResponseData()
        else {
            return .error(StringErrorOutput(try? signatureResponse.getErrorMessage() ?? cardDetailResponse.getErrorMessage()))
        }
        return .ok(SetupAddToApplePayUseCaseOKOutput(operativeConfig: operativeConfig, cardDetail: CardDetail.create(detail, cardDataDTO: nil, clientName: ""), signatureWithToken: signatureWithToken))
    }
}

struct SetupAddToApplePayUseCaseInput {
    let card: Card?
}

struct SetupAddToApplePayUseCaseOKOutput {
    var operativeConfig: OperativeConfig
    let cardDetail: CardDetail
    let signatureWithToken: SignatureWithToken
}

extension SetupAddToApplePayUseCaseOKOutput: SetupUseCaseOkOutputProtocol {}
