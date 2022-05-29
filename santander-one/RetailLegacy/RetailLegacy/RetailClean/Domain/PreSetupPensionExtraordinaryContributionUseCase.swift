import CoreFoundationLib
import Foundation
import SANLegacyLibrary


class PreSetupPensionExtraordinaryContributionUseCase: UseCase<PreSetupPensionExtraordinaryContributionUseCaseInput, PreSetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository) {
        self.provider = managersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: PreSetupPensionExtraordinaryContributionUseCaseInput) throws -> UseCaseResponse<PreSetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
        guard
            requestValues.pension == nil
            else { return .ok(PreSetupPensionExtraordinaryContributionUseCaseOkOutput(pensions: [])) }
        
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: provider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        let enabledPensionOperations = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigPensionOperationsEnabled)
        guard
            let pgWrapper = merger.globalPositionWrapper,
            enabledPensionOperations == true
            else { return .error(StringErrorOutput(nil)) }
        let allianzProducts = accountDescriptorRepository.get()?.plansArray.map(ProductAllianz.init) ?? []
        let pensionList = pgWrapper.pensions.getVisibles().filter { !$0.isAllianz(filterWith: allianzProducts) }
        guard
            pensionList.count > 0
            else { return .error(StringErrorOutput("deeplink_alert_errorExtraContribution")) }
        return UseCaseResponse.ok(PreSetupPensionExtraordinaryContributionUseCaseOkOutput(pensions: pensionList))
    }
}

struct PreSetupPensionExtraordinaryContributionUseCaseInput {
    let pension: Pension?
}

struct PreSetupPensionExtraordinaryContributionUseCaseOkOutput {
    let pensions: [Pension]
}
