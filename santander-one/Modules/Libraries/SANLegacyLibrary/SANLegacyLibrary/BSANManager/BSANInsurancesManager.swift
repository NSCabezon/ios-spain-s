public protocol BSANInsurancesManager {
    func getInsuranceData(contractId: String) throws -> BSANResponse<InsuranceDataDTO>
    func getParticipants(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceParticipantDTO]>
    func getBeneficiaries(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceBeneficiaryDTO]>
    func getCoverages(policyId: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceCoverageDTO]>
}
