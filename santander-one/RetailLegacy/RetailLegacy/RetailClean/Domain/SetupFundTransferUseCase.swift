import SANLegacyLibrary
import CoreFoundationLib

class SetupFundTransferUseCase: SetupUseCase<SetupFundTransferUseCaseInput, SetupFundTransferUseCaseOkOutput, SetupFundTransferUseCaseErrorOutput> {
    private let provider: BSANManagersProvider

    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.provider = managersProvider
        super.init(appConfigRepository: appConfigRepository)
    }

    override func executeUseCase(requestValues: SetupFundTransferUseCaseInput) throws -> UseCaseResponse<SetupFundTransferUseCaseOkOutput, SetupFundTransferUseCaseErrorOutput> {

        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig

        let fundsManager = provider.getBsanFundsManager()
        let dto = requestValues.fund.fundDTO
        
        let responseAccount = try provider.getBsanAccountsManager().getAccount(fromOldContract: dto.contract)
        var account: Account?

        if responseAccount.isSuccess(), let accountDTO = try responseAccount.getResponseData() {
            account = Account.create(accountDTO)
        }

        let response = try fundsManager.getFundDetail(forFund: dto)

        guard response.isSuccess(), let detail = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(SetupFundTransferUseCaseErrorOutput(errorDescription))
        }
        if let blackList = appConfigRepository.getAppConfigListNode("blockFundOffices"), let branchCode = detail.linkedAccount?.branchCode, blackList.contains(branchCode) {
            return UseCaseResponse.error(SetupFundTransferUseCaseErrorOutput(nil))
        }

        let productFundsList: [FundDTO]

        if let funds = requestValues.productFundList {
            productFundsList = funds.map({ $0.fundDTO }).filter({ !Fund(dto: $0).isAllianz })
        } else {
            let gPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
            guard let funds = gPositionDTO?.funds else {
                return UseCaseResponse.error(SetupFundTransferUseCaseErrorOutput(nil))
            }
            productFundsList = funds
        }

        return UseCaseResponse.ok(SetupFundTransferUseCaseOkOutput(operativeConfig: operativeConfig, fundDetail: FundDetail.create(dto, detailDTO: detail), fundList: FundList.create(productFundsList), account: account))

    }
}

struct SetupFundTransferUseCaseInput {
    let fund: Fund
    let productFundList: [Fund]?
}

struct SetupFundTransferUseCaseOkOutput {
    var operativeConfig: OperativeConfig
    let fundDetail: FundDetail
    let fundList: FundList
    let account: Account?
}

extension SetupFundTransferUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
}

class SetupFundTransferUseCaseErrorOutput: StringErrorOutput {

}
