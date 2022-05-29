import SANLegacyLibrary

struct MockBSANLoanSimulatorManager: BSANLoanSimulatorManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }

    func getActiveCampaigns() throws -> BSANResponse<CampaignsCheckLoanSimulatorDTO> {
        let dto = mockDataInjector.mockDataProvider.loanSimulatorData.getActiveCampaignsMock
        return BSANOkResponse(dto)
    }
    
    func loadLimits(input: LoadLimitsInput, selectedCampaignCurrency: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getLimits() throws -> BSANResponse<LoanSimulatorProductLimitsDTO> {
        let dto = mockDataInjector.mockDataProvider.loanSimulatorData.limitsMock
        return BSANOkResponse(dto)
    }
    
    func doSimulation(inputData: LoanSimulatorDataSend) throws -> BSANResponse<LoanSimulatorConditionsDTO> {
        let dto = mockDataInjector.mockDataProvider.loanSimulatorData.doSimulationMock
        return BSANOkResponse(dto)
    }
}
