public protocol WebServicesUrlProvider {
    func getClientId() throws -> String
    func getClientSecret() throws -> String
    func getLoginUrl() -> String
    func getInsuranceDataUrl( contractId: String) -> String
    func getParticipantsUrl( policyId: String)-> String
    func getBeneficiariesUrl( policyId: String)-> String
    func getCoveragesUrl( policyId: String)-> String
    func setShouldUsePass2Urls(_ shouldUse: Bool)
    func setUrlsForMulMov(_ urls: [String])
    func isMulMovActivate(_ url: String) -> Bool
}
