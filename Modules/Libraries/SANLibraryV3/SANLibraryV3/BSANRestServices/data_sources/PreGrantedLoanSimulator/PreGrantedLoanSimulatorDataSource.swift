protocol PreGrantedLoanSimulatorDataSource {
    func checkActive(channel: String, companyId: String) throws -> BSANResponse<CampaignsCheckLoanSimulatorDTO>
    func limitManager(body: CampaignQueryDTO) throws -> BSANResponse<LoanSimulatorLimitDTO>
    func simulation(body: LoanSimulationDTO) throws -> BSANResponse<LoanSimulatorConditionsDTO>
}
