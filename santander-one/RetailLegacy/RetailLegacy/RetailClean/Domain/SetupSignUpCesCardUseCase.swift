import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupSignUpCesCardUseCase: SetupUseCase<SetupSignUpCesCardUseCaseInput, SetupSignUpCesCardUseCaseOkOutput, SetupSignUpCesCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupSignUpCesCardUseCaseInput) throws -> UseCaseResponse<SetupSignUpCesCardUseCaseOkOutput, SetupSignUpCesCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let cardDTO = requestValues.card.cardDTO
        
        let cardDetailDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardDetail(cardDTO: cardDTO))
        let cardDataDTO = try checkRepositoryResponse(provider.getBsanCardsManager().getCardData(cardDTO.formattedPAN!))
        let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
        let cardDetail = CardDetail.create(cardDetailDTO!, cardDataDTO: cardDataDTO, clientName: globalPositionDTO!.clientName ?? "")

        let responseDetail = try provider.getBsanCardsManager().getCardDetailToken(cardDTO: cardDTO, cardTokenType: CardTokenType.panWithoutSpaces)

        if responseDetail.isSuccess() {
            if let codApli = try responseDetail.getResponseData()?.codAplic, codApli.uppercased().elementsEqual("MP") {
                let responsePhone = try provider.getBsanSendMoneyManager().loadCMPSStatus()
                let phoneNumber = responsePhone.isSuccess() ? try responsePhone.getResponseData()?.otpPhoneDecrypted : ""
                
                if let phoneNumber = phoneNumber {
                    let phoneNumber = self.validateOtpPhoneNumber(phoneNumber: phoneNumber.notWhitespaces()) ? phoneNumber : ""
                    
                    return UseCaseResponse.ok(SetupSignUpCesCardUseCaseOkOutput(operativeConfig: operativeConfig, allowsCesSignup: cardDetail.allowsCesSignup, cesCard: CesCard(phoneNumber: phoneNumber), cardDetail: cardDetail))
                }
            } else {
                return UseCaseResponse.error(SetupSignUpCesCardUseCaseErrorOutput("generic_alert_errorCard"))
            }
        }
        return UseCaseResponse.error(SetupSignUpCesCardUseCaseErrorOutput(try responseDetail.getErrorMessage()))
    }
    
    func validateOtpPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.count >= 9 {
            let PHONE_REGEX: String = "^((\\+0*[1-9]?[0-9]?)|(\\(\\+?0*[1-9]?[0-9]*\\)?)|(0+[1-9]?[0-9]?))?0*(([1-9][0-9]{0,2})([0-9][0-9]{0,2})?0*([0-9][0-9]{0,2})?)?"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
            return phoneTest.evaluate(with: phoneNumber)
        }
        return false
    }
}

struct SetupSignUpCesCardUseCaseInput {
    let card: Card
}

struct SetupSignUpCesCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    var allowsCesSignup: Bool
    var cesCard: CesCard
    var cardDetail: CardDetail
}

extension SetupSignUpCesCardUseCaseOkOutput: OperativeParameter {}

extension SetupSignUpCesCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupSignUpCesCardUseCaseErrorOutput: StringErrorOutput {
}
