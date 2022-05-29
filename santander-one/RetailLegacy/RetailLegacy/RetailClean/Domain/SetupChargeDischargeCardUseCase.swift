import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupChargeDischargeCardUseCase: SetupUseCase<SetupChargeDischargeCardUseCaseInput, SetupChargeDischargeCardUseCaseOkOutput, SetupChargeDischargeCardUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupChargeDischargeCardUseCaseInput) throws -> UseCaseResponse<SetupChargeDischargeCardUseCaseOkOutput, SetupChargeDischargeCardUseCaseErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let response = try provider.getBsanCardsManager().loadPrepaidCardData(cardDTO: requestValues.card.cardDTO)
        
        guard response.isSuccess() else {
            return UseCaseResponse.error(SetupChargeDischargeCardUseCaseErrorOutput(try response.getErrorCode()))
        }
        
        let cardsResponse = try provider.getBsanCardsManager().getPrepaidCardData(cardDTO: requestValues.card.cardDTO)

        guard cardsResponse.isSuccess(), let prepaidCardDataDTO = try cardsResponse.getResponseData() else {
            return UseCaseResponse.error(SetupChargeDischargeCardUseCaseErrorOutput(try response.getErrorCode()))
        }
        
        let topUpOptions = appConfigRepository.getAppConfigListNode("chargePrepaidCardAmounts") ?? []
        let withdrawOptions = appConfigRepository.getAppConfigListNode("dischargePrepaidCardAmounts") ?? []

        let accountList = requestValues.accountList
        let valids = accountList?.list.filter { requestValues.card.getContractDTO() != $0.accountDTO.oldContract && !$0.isPiggyBankAccount }
        
        return UseCaseResponse.ok(SetupChargeDischargeCardUseCaseOkOutput(operativeConfig: operativeConfig, prepaidCardData: PrepaidCardData(dto: prepaidCardDataDTO), accountsList: AccountList(valids ?? []), topUpOptions: topUpOptions, withdrawOptions: withdrawOptions))
    }
}

struct SetupChargeDischargeCardUseCaseInput {
    let card: Card
    let accountList: AccountList?
}
struct SetupChargeDischargeCardUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let prepaidCardData: PrepaidCardData
    let accountsList: AccountList
    let topUpOptions: [String]
    let withdrawOptions: [String]
}

extension SetupChargeDischargeCardUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupChargeDischargeCardUseCaseErrorOutput: StringErrorOutput {}
