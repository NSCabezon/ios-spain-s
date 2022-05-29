import SANLegacyLibrary
import CoreFoundationLib

class GetInsuranceDataUseCase: UseCase<GetInsuranceDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetInsuranceDataUseCaseInput) throws -> UseCaseResponse<GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let dto = requestValues.insurance.insuranceDTO
        let response = try insurancesmanager.getInsuranceData(contractId: dto.contract?.contratoPKWithNoSpaces ?? "")
        if response.isSuccess(), let insuranceData = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceDataUseCaseOkOutput(insuranceData: InsuranceData(insuranceData)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceDataUseCaseErrorOutput(errorDescription))
        
    }
    
}

class GetInsuranceSavingDataUseCase: UseCase<GetInsuranceSavingDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetInsuranceSavingDataUseCaseInput) throws -> UseCaseResponse<GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let dto = requestValues.insurance.insuranceDTO
        
        let response = try insurancesmanager.getInsuranceData(contractId: dto.contract?.contratoPKWithNoSpaces ?? "")
        
        if response.isSuccess(), let insuranceData = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceDataUseCaseOkOutput(insuranceData: InsuranceData(insuranceData)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceDataUseCaseErrorOutput(errorDescription))
        
    }
    
}

struct GetInsuranceDataUseCaseInput {

    let insurance: InsuranceProtection
    
    init(insurance: InsuranceProtection) {
        self.insurance = insurance
    }
    
}

struct GetInsuranceSavingDataUseCaseInput {
    
    let insurance: InsuranceSaving
    
    init(insurance: InsuranceSaving) {
        self.insurance = insurance
    }
    
}

struct GetInsuranceDataUseCaseOkOutput {
 
    let insuranceData: InsuranceData
    
    init(insuranceData: InsuranceData) {
        self.insuranceData = insuranceData
    }
}

class GetInsuranceDataUseCaseErrorOutput: StringErrorOutput {
    
}
