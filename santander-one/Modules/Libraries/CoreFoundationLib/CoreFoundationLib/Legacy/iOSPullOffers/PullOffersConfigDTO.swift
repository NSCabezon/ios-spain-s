public struct PullOffersConfigDTO: Codable {
    public let pullOffersConfig: PullOffersContainerConfigDTO
    public let homeTips: [PullOffersHomeTipsDTO]?
    public let interestTips: [PullOffersHomeTipsDTO]?
}
