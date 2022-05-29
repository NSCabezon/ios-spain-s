import Foundation
import CoreFoundationLib
import SANLegacyLibrary


class GetIsAnalysisAreaEnabledUseCase: UseCase<Void, GetIsAnalysisAreaEnabledUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository

    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetIsAnalysisAreaEnabledUseCaseOkOutput, StringErrorOutput> {
        //GlobalPositionWrapper
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPosition = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let analysisNodeEnabled = self.appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigAnalysisEnabled) ?? false
        let isAnalysisEnabled = globalPosition.accounts.getVisibles().count > 0
            || globalPosition.cards.getVisibles().count > 0
            || globalPosition.loans.getVisibles().count > 0
            && analysisNodeEnabled
        
        return UseCaseResponse.ok(GetIsAnalysisAreaEnabledUseCaseOkOutput(isEnabled: isAnalysisEnabled))
    }
}

struct GetIsAnalysisAreaEnabledUseCaseOkOutput {
    let isEnabled: Bool
}
