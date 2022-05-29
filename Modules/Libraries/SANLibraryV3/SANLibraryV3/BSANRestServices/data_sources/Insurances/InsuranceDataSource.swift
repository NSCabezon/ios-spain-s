public protocol InsuranceDataSource{
    func getInsuranceData(absoluteUrl: String) throws -> BSANResponse<InsuranceDataDTO>
    func getParticipants(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceParticipantDTO]>
    func getBeneficiaries(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceBeneficiaryDTO]>
    func getCoverages(absoluteUrl: String, familyId: String, thirdPartyInd: String, factoryPolicyNumber: String, contractId: String) throws -> BSANResponse<[InsuranceCoverageDTO]>
}
