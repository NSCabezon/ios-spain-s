import SANLegacyLibrary
import CoreFoundationLib

class SetupFundSubscriptionUseCase: SetupUseCase<SetupFundSubscriptionUseCaseInput, SetupFundSubscriptionUseCaseOkOutput, SetupFundSubscriptionUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupFundSubscriptionUseCaseInput) throws -> UseCaseResponse<SetupFundSubscriptionUseCaseOkOutput, SetupFundSubscriptionUseCaseErrorOutput> {
        
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let fundsManager = provider.getBsanFundsManager()
        let dto = requestValues.fund.fundDTO
        var account: Account?
        
        let responseAccount = try provider.getBsanAccountsManager().getAccount(fromOldContract: dto.contract)
        if responseAccount.isSuccess(), let accountDto = try responseAccount.getResponseData() {
            account = Account.create(accountDto)
        }
        
        let response = try fundsManager.getFundDetail(forFund: dto)
        
        if response.isSuccess(), let detail = try response.getResponseData() {
            if let blackList = appConfigRepository.getAppConfigListNode("blockFundOffices"), let branchCode = detail.linkedAccount?.branchCode {
                if blackList.contains(branchCode) {
                    return UseCaseResponse.error(SetupFundSubscriptionUseCaseErrorOutput(nil))
                }
            }
            return UseCaseResponse.ok(SetupFundSubscriptionUseCaseOkOutput(fundDetail: FundDetail.create(dto, detailDTO: detail), account: account, operativeConfig: operativeConfig))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(SetupFundSubscriptionUseCaseErrorOutput(errorDescription))
    }
}

struct SetupFundSubscriptionUseCaseInput {
    let fund: Fund
}

struct SetupFundSubscriptionUseCaseOkOutput {
    let fundDetail: FundDetail
    let account: Account?
    var operativeConfig: OperativeConfig
}

extension SetupFundSubscriptionUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupFundSubscriptionUseCaseErrorOutput: StringErrorOutput {
    
}
