import SANLegacyLibrary
import CoreFoundationLib

class SetupMobileTopUpUseCase: SetupUseCase<SetupMobileTopUpUseCaseInput, SetupMobileTopUpUseCaseOkOutput, SetupMobileTopUpUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupMobileTopUpUseCaseInput) throws -> UseCaseResponse<SetupMobileTopUpUseCaseOkOutput, SetupMobileTopUpUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        let card = requestValues.card.cardDTO
        let response = try provider.getBsanMobileRechargeManager().getMobileOperators(card: card)
        
        if response.isSuccess(), let response = try response.getResponseData() {
            let mobileOperatorList = MobileOperatorList(mobileOperatorListDTO: response)
            return UseCaseResponse.ok(SetupMobileTopUpUseCaseOkOutput(operativeConfig: operativeConfig, mobileOperatorList: mobileOperatorList))
        }
        
        return UseCaseResponse.error(SetupMobileTopUpUseCaseErrorOutput(nil))
    }
}

struct SetupMobileTopUpUseCaseInput {
    let card: Card
}

struct SetupMobileTopUpUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
    let mobileOperatorList: MobileOperatorList
}

class SetupMobileTopUpUseCaseErrorOutput: StringErrorOutput {
    
}
