import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class IsMoneyPlanEnabled: UseCase<Void, IsMoneyPlanEnabledOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsMoneyPlanEnabledOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(IsMoneyPlanEnabledOkOutput(isMoneyPlanEnabled: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigMoneyPlanEnabled), isMoneyPlanNativeMode: appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigMoneyNativeMode)))
    }
}

struct IsMoneyPlanEnabledOkOutput {
    let isMoneyPlanEnabled: Bool?
    let isMoneyPlanNativeMode: Bool?
}
