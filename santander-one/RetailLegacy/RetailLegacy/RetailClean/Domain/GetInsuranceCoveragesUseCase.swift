import SANLegacyLibrary
import CoreFoundationLib

class GetInsuranceCoveragesUseCase: UseCase<GetInsuranceCoveragesUseCaseInput, GetInsuranceCoveragesUseCaseOkOutput, GetInsuranceCoveragesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetInsuranceCoveragesUseCaseInput) throws -> UseCaseResponse<GetInsuranceCoveragesUseCaseOkOutput, GetInsuranceCoveragesUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let insuranceDto = requestValues.insurance.insuranceDTO
        
        let response = try insurancesmanager.getCoverages(policyId: requestValues.insuranceData.policyId ?? "", familyId: requestValues.insuranceData.familyId ?? "", thirdPartyInd: requestValues.insuranceData.thirdPartyInd ?? "", factoryPolicyNumber: requestValues.insuranceData.factoryPolicyNumber ?? "", contractId: insuranceDto.contract?.contratoPKWithNoSpaces ?? "")
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceCoveragesUseCaseOkOutput(coverageList: InsuranceCoverageList.create(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceCoveragesUseCaseErrorOutput(errorDescription))
        
    }
    
}

struct GetInsuranceCoveragesUseCaseInput {
    
    let insurance: InsuranceProtection
    let insuranceData: InsuranceData
    
    init(insurance: InsuranceProtection, insuranceData: InsuranceData) {
        self.insurance = insurance
        self.insuranceData = insuranceData
    }
    
}

struct GetInsuranceCoveragesUseCaseOkOutput {
    
    let coverageList: InsuranceCoverageList
    
    init(coverageList: InsuranceCoverageList) {
        self.coverageList = coverageList
    }
}

class GetInsuranceCoveragesUseCaseErrorOutput: StringErrorOutput {
    
}
