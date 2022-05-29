import SANLegacyLibrary
import CoreFoundationLib

class GetInsuranceBeneficiariesUseCase: UseCase<GetInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetInsuranceBeneficiariesUseCaseInput) throws -> UseCaseResponse<GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let insuranceDto = requestValues.insurance.insuranceDTO

        let response = try insurancesmanager.getBeneficiaries(policyId: requestValues.insuranceData.policyId ?? "", familyId: requestValues.insuranceData.familyId ?? "", thirdPartyInd: requestValues.insuranceData.thirdPartyInd ?? "", factoryPolicyNumber: requestValues.insuranceData.factoryPolicyNumber ?? "", contractId: insuranceDto.contract?.contratoPKWithNoSpaces ?? "")

        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceBeneficiariesUseCaseOkOutput(beneficiaryList: InsuranceBeneficiaryList.create(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceBeneficiariesUseCaseErrorOutput(errorDescription))

    }
    
}

class GetSavingInsuranceBeneficiariesUseCase: UseCase<GetSavingInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetSavingInsuranceBeneficiariesUseCaseInput) throws -> UseCaseResponse<GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let insuranceDto = requestValues.insurance.insuranceDTO

        let response = try insurancesmanager.getBeneficiaries(policyId: requestValues.insuranceData.policyId ?? "", familyId: requestValues.insuranceData.familyId ?? "", thirdPartyInd: requestValues.insuranceData.thirdPartyInd ?? "", factoryPolicyNumber: requestValues.insuranceData.factoryPolicyNumber ?? "", contractId: insuranceDto.contract?.contratoPKWithNoSpaces ?? "")
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceBeneficiariesUseCaseOkOutput(beneficiaryList: InsuranceBeneficiaryList.create(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceBeneficiariesUseCaseErrorOutput(errorDescription))
    }
    
}
struct GetInsuranceBeneficiariesUseCaseInput {
    
    let insurance: InsuranceProtection
    let insuranceData: InsuranceData
    
    init(insurance: InsuranceProtection, insuranceData: InsuranceData) {
        self.insurance = insurance
        self.insuranceData = insuranceData
    }
    
}

struct GetSavingInsuranceBeneficiariesUseCaseInput {
    
    let insurance: InsuranceSaving
    let insuranceData: InsuranceData
    
    init(insurance: InsuranceSaving, insuranceData: InsuranceData) {
        self.insurance = insurance
        self.insuranceData = insuranceData
    }
    
}

struct GetInsuranceBeneficiariesUseCaseOkOutput {
    
    let beneficiaryList: InsuranceBeneficiaryList
    
    init(beneficiaryList: InsuranceBeneficiaryList) {
        self.beneficiaryList = beneficiaryList
    }
}

class GetInsuranceBeneficiariesUseCaseErrorOutput: StringErrorOutput {
    
}
