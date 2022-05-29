import SANLegacyLibrary

struct MockBSANScaManager: BSANScaManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }

    func checkSca() throws -> BSANResponse<CheckScaDTO> {
        let dto = mockDataInjector.mockDataProvider.scaData.checkScaMock
        return BSANOkResponse(dto)
    }
    
    func loadCheckSca() throws -> BSANResponse<CheckScaDTO> {
        let dto = mockDataInjector.mockDataProvider.scaData.checkScaMock
        return BSANOkResponse(dto)
    }
    
    func isScaOtpOkForAccounts() throws -> BSANResponse<Bool> {
        let dto = mockDataInjector.mockDataProvider.scaData.isScaOtpOkForAccountsMock
        return BSANOkResponse(dto)
    }
    
    func saveScaOtpLoginTemporaryBlock() throws {}
    
    func saveScaOtpAccountTemporaryBlock() throws {}
    
    func isScaOtpAskedForLogin() throws -> BSANResponse<Bool> {
        let dto = mockDataInjector.mockDataProvider.scaData.isScaOtpAskedForLoginMock
        return BSANOkResponse(dto)    }
    
    func validateSca(forwardIndicator: Bool, foceSMS: Bool, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ValidateScaDTO> {
        let dto = mockDataInjector.mockDataProvider.scaData.validateScaMock
        return BSANOkResponse(dto)
    }
    
    func confirmSca(tokenOTP: String?, ticketOTP: String?, codeOTP: String, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ConfirmScaDTO> {
        let dto = mockDataInjector.mockDataProvider.scaData.confirmScaMock
        return BSANOkResponse(dto)
    }
}
