import SANLegacyLibrary

struct MockBSANInsurancesManager: BSANInsurancesManager {
    func getInsuranceData(contractId: String) throws -> BSANResponse<InsuranceDataDTO> {
        fatalError()
    }
    
    func getParticipants(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceParticipantDTO]> {
        fatalError()
    }
    
    func getBeneficiaries(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceBeneficiaryDTO]> {
        fatalError()
    }
    
    func getCoverages(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceCoverageDTO]> {
        fatalError()
    }
}
