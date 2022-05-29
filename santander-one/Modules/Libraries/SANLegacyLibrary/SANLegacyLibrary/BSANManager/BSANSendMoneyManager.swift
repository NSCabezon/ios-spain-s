public protocol BSANSendMoneyManager {
    func getCMPSStatus() throws -> BSANResponse<CMPSDTO>
    func loadCMPSStatus() throws -> BSANResponse<CMPSDTO>
}
