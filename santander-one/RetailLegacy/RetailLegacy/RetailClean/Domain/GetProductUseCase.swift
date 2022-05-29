import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class GetProductUseCase: UseCase<Void, GetProductUseCaseOKOutput, GetProductUseCaseErrorOutput> {

    private var appConfigRepository: AppConfigRepository
    private var accountDescriptorRepository: AccountDescriptorRepository
    private var bsanManagersProvider: BSANManagersProvider

    init(appConfigRepository: AppConfigRepository, accountDescriptorRepository: AccountDescriptorRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.bsanManagersProvider = bsanManagersProvider
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetProductUseCaseOKOutput, GetProductUseCaseErrorOutput> {

        let ispB = try checkRepositoryResponse(bsanManagersProvider.getBsanSessionManager().isPB())
        let isDemo = try checkRepositoryResponse(bsanManagersProvider.getBsanSessionManager().isDemo())
        let globalPosition = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let hasFundsTransfer = checkHasFundTransfers(globalPosition: globalPosition)
        
        let cmps = CMPS.createFromDTO(dto: try checkRepositoryResponse(try bsanManagersProvider.getBsanSendMoneyManager().getCMPSStatus()))
        let productConfig = ProductConfig(isPB: ispB,
                isDemo: isDemo,
                isOTPExcepted: cmps.isOTPExcepted,
                hasTranferFunds: hasFundsTransfer,
                enableMoneyPlanPromotion: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigMoneyPlanEnabled),
                moneyPlanNativeMode: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigMoneyNativeMode),
                isSavingInsuranceBalanceEnabled: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceBalanceEnabled),
                enabledLoanOperations: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigLoanOperationsEnabled),
                enabledPensionOperations: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigPensionOperationsEnabled),
                enablePayLater: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCardPayLater),
                enableDirectMoney: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigCardDirectMoney),
                isEnabledCardLimitManagement: isEnabledCardLimitManagement(),
                enableAccountTransactionsPdf: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableAccountTransactionsPdf),
                fundOperationsSubcriptionNativeMode: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigFundOperationsSubcriptionNativeMode),
                fundOperationsTransferNativeMode: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigFundOperationsTransferNativeMode),
                enableBroker: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableBroker),
                stocksNativeMode: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigStocksNativeMode),
                allianzProducts: accountDescriptorRepository.get()?.plansArray.map(ProductAllianz.init) ?? [])
        return UseCaseResponse.ok(GetProductUseCaseOKOutput(productConfig: productConfig))
    }

    private func checkHasFundTransfers(globalPosition: GlobalPositionDTO?) -> Bool {
        if let globalPosition = globalPosition, let funds = globalPosition.funds, funds.count > 1 {
            let fundList = FundList.create(funds)
            let allianzFunds = fundList.getAllianzFundsNumber()
            return fundList.getProductCount() - allianzFunds > 1
        }
        return false
    }
    
    private func isEnabledCardLimitManagement() -> Bool {
        let isEnabledSuperspeed = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableCardSuperSpeed) ?? false
        
        return isEnabledSuperspeed
    }
}

struct GetProductUseCaseOKOutput {
    var productConfig: ProductConfig?
}

class GetProductUseCaseErrorOutput: StringErrorOutput {}
