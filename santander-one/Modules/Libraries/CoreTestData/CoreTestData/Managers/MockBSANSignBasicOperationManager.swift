import SANLegacyLibrary

struct MockBSANSignBasicOperationManager: BSANSignBasicOperationManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getSignaturePattern() throws -> BSANResponse<GetSignPatternDTO> {
        let dto = self.mockDataInjector.mockDataProvider.bsanSignBasicData.getSignaturePattern
        return BSANOkResponse(dto)
    }
    
    func startSignPattern(_ pattern: String, instaID: String) throws -> BSANResponse<SignBasicOperationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.bsanSignBasicData.getSignBasicOperation
        return BSANOkResponse(dto)
    }
    
    func validateSignPattern(_ input: SignValidationInputParams) throws -> BSANResponse<SignBasicOperationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.bsanSignBasicData.getSignBasicOperation
        return BSANOkResponse(dto)
    }
    
    func getContractCmc() throws -> String {
        return self.mockDataInjector.mockDataProvider.bsanSignBasicData.getContractCmc
    }
}
