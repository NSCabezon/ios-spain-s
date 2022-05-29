import Foundation

public struct PullOffersFinanceableCommercialOfferDTO: Codable {
    public let header: PullOffersFinanceableCommercialOfferHeaderDTO
    public let offers: [PullOffersFinanceableCommercialOfferPillDTO]?
}

public struct PullOffersFinanceableCommercialOfferHeaderDTO: Codable {
    public let title: String?
    public let subtitle: String?
}

public struct PullOffersFinanceableCommercialOfferPillDTO: Codable {
    public let title: String?
    public let desc: String?
    public let icon: String?
    public let locationId: String?
}
