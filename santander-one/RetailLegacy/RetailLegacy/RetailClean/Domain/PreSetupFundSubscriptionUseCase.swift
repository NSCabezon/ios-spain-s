import SANLegacyLibrary
import CoreFoundationLib


class PreSetupFundSubscriptionUseCase: UseCase<PreSetupFundSubscriptionUseCaseInput, PreSetupFundSubscriptionUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider,
         appConfigRepository: AppConfigRepository,
         appRepository: AppRepository,
         accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: PreSetupFundSubscriptionUseCaseInput) throws -> UseCaseResponse<PreSetupFundSubscriptionUseCaseOkOutput, StringErrorOutput> {
        if requestValues.fund != nil {
            return UseCaseResponse.ok(PreSetupFundSubscriptionUseCaseOkOutput(funds: []))
        } else {
            let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider,
                                                       appRepository: appRepository,
                                                       accountDescriptorRepository: accountDescriptorRepository,
                                                       appConfigRepository: appConfigRepository).merge()

            let enabledFundSubscription = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigFundOperationsSubcriptionNativeMode)
            let isDemo = try checkRepositoryResponse(provider.getBsanSessionManager().isDemo()) ?? false
            guard let pgWrapper = merger.globalPositionWrapper, enabledFundSubscription == true && (!pgWrapper.isPb || isDemo) else {
                return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorSubscriptionFunds"))
            }
            let fundList = pgWrapper.funds.getVisibles().filter {
                return !$0.isAllianz
            }
            guard fundList.count > 0 else {
                return UseCaseResponse.error(StringErrorOutput("deeplink_alert_errorSubscriptionFunds"))
            }
            return UseCaseResponse.ok(PreSetupFundSubscriptionUseCaseOkOutput(funds: fundList))
        }
    }
}

struct PreSetupFundSubscriptionUseCaseInput {
    let fund: Fund?
}

struct PreSetupFundSubscriptionUseCaseOkOutput {
    let funds: [Fund]
}

extension PreSetupFundSubscriptionUseCase: AssociatedAccountRetriever {}
