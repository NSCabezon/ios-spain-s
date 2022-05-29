public protocol BSANLoanSimulatorManager {
    func getActiveCampaigns() throws -> BSANResponse<CampaignsCheckLoanSimulatorDTO>
    func loadLimits(input: LoadLimitsInput, selectedCampaignCurrency: String) throws -> BSANResponse<Void>
    func getLimits() throws -> BSANResponse<LoanSimulatorProductLimitsDTO>
    func doSimulation(inputData: LoanSimulatorDataSend) throws -> BSANResponse<LoanSimulatorConditionsDTO>
}

