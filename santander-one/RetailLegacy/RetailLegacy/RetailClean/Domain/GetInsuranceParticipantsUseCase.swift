import SANLegacyLibrary
import CoreFoundationLib

class GetInsuranceParticipantsUseCase: UseCase<GetInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetInsuranceParticipantsUseCaseInput) throws -> UseCaseResponse<GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let insuranceDto = requestValues.insurance.insuranceDTO
        
        let response = try insurancesmanager.getParticipants(policyId: requestValues.insuranceData.policyId ?? "", familyId: requestValues.insuranceData.familyId ?? "", thirdPartyInd: requestValues.insuranceData.thirdPartyInd ?? "", factoryPolicyNumber: requestValues.insuranceData.factoryPolicyNumber ?? "", contractId: insuranceDto.contract?.contratoPKWithNoSpaces ?? "")
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceParticipantsUseCaseOkOutput(participantList: InsuranceParticipantList.create(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceParticipantsUseCaseErrorOutput(errorDescription))
        
    }
    
}

class GetSavingInsuranceParticipantsUseCase: UseCase<GetSavingInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetSavingInsuranceParticipantsUseCaseInput) throws -> UseCaseResponse<GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
        let insurancesmanager = provider.getBsanInsurancesManager()
        let insuranceDto = requestValues.insurance.insuranceDTO
        
        let response = try insurancesmanager.getParticipants(policyId: requestValues.insuranceData.policyId ?? "", familyId: requestValues.insuranceData.familyId ?? "", thirdPartyInd: requestValues.insuranceData.thirdPartyInd ?? "", factoryPolicyNumber: requestValues.insuranceData.factoryPolicyNumber ?? "", contractId: insuranceDto.contract?.contratoPKWithNoSpaces ?? "")
        
        if response.isSuccess(), let list = try response.getResponseData() {
            return UseCaseResponse.ok(GetInsuranceParticipantsUseCaseOkOutput(participantList: InsuranceParticipantList.create(list)))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(GetInsuranceParticipantsUseCaseErrorOutput(errorDescription))
        
    }
    
}
struct GetInsuranceParticipantsUseCaseInput {
    
    let insurance: InsuranceProtection
    let insuranceData: InsuranceData
    
    init(insurance: InsuranceProtection, insuranceData: InsuranceData) {
        self.insurance = insurance
        self.insuranceData = insuranceData
    }
    
}

struct GetSavingInsuranceParticipantsUseCaseInput {
    
    let insurance: InsuranceSaving
    let insuranceData: InsuranceData
    
    init(insurance: InsuranceSaving, insuranceData: InsuranceData) {
        self.insurance = insurance
        self.insuranceData = insuranceData
    }

}

struct GetInsuranceParticipantsUseCaseOkOutput {
    
    let participantList: InsuranceParticipantList
    
    init(participantList: InsuranceParticipantList) {
        self.participantList = participantList
    }
}

class GetInsuranceParticipantsUseCaseErrorOutput: StringErrorOutput {
    
}
