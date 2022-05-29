import Foundation

public struct PullOffersConfigBudgetDTO: Codable {
    public let identifier: String
    public let currentSpentBudget, currentDay: PullOffersConfigCurrentBudgetDTO
    public let title: String
    public let icon: String?
    public let offersID: [String]?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case currentSpentBudget, currentDay, title, icon
        case offersID = "offersId"
    }
}

public struct PullOffersConfigCurrentBudgetDTO: Codable {
    public let greaterAndEqualThan: String
    public let lessThan: String?
}
