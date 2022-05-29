import Foundation

public struct CampaignDTO: Codable {
    public var idRule: String?
    public var title: String?
    public var urlCommercialContact: String?
    public var urlCommercialContactEng: String?
    public var buttonType: Int?
    public var indActivateFunction: Int?
    public var indShowCheck: Int?
    public var activationDateString: String?
    public var activationDate: Date?
    public var deactivationDateString: String?
    public var deactivationDate: Date?
    public var indPriority: Int?
    public var urlButton: String?
}
