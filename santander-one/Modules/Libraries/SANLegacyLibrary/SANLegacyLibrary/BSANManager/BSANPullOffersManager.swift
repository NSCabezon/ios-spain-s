public protocol BSANPullOffersManager {
    func getCampaigns() throws -> BSANResponse<[String]?>
    func loadCampaigns() throws -> BSANResponse<Void>
}
