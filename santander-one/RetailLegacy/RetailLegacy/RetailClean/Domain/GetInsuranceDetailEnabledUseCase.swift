import CoreFoundationLib

class GetInsuranceDetailEnabledUseCase: UseCase<Void, GetInsuranceDetailEnabledUseCaseOkOutput, GetInsuranceDetailEnabledUseCaseErrorOutput> {
    private var appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetInsuranceDetailEnabledUseCaseOkOutput, GetInsuranceDetailEnabledUseCaseErrorOutput> {
        
        let insuranceDetailEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceDetailEnabled) ?? false
        let insuranceBalanceEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigInsuranceBalanceEnabled) ?? false
        
        return UseCaseResponse.ok(GetInsuranceDetailEnabledUseCaseOkOutput(insuranceDetailEnabled: insuranceDetailEnabled, isInsuranceBalanceEnabled: insuranceBalanceEnabled))
    }
    
}

struct GetInsuranceDetailEnabledUseCaseOkOutput {
    let insuranceDetailEnabled: Bool
    let isInsuranceBalanceEnabled: Bool
}

class GetInsuranceDetailEnabledUseCaseErrorOutput: StringErrorOutput {
    
}
