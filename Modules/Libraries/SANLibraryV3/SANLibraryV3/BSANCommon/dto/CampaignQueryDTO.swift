import Foundation

public struct CampaignQueryDTO: Encodable {
    public let employee: Bool?
    public let group: String?
    public let channel: String?
    public let companyId: String?
    public let campaigns: [LoanSimulatorCampaignDTO]?
    public let smartInd: String?
    public let accountInd: String?
    public let customerSegment: String?

    enum CodingKeys: String, CodingKey {
        case employee = "employee"
        case group = "group"
        case channel = "channel"
        case companyId = "companyId"
        case campaigns = "campaigns"
        case smartInd = "smartInd"
        case accountInd = "accountInd"
        case customerSegment = "customerSegment"
    }

    public init(employee: Bool?, group: String?, channel: String?, companyId: String?, campaigns: [LoanSimulatorCampaignDTO]?, smartInd: String?, accountInd: String?, customerSegment: String?) {
        self.employee = employee
        self.group = group
        self.channel = channel
        self.companyId = companyId
        self.campaigns = campaigns
        self.smartInd = smartInd
        self.accountInd = accountInd
        self.customerSegment = customerSegment
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(employee, forKey: .employee)
        try container.encode(group, forKey: .group)
        try container.encode(channel, forKey: .channel)
        try container.encode(companyId, forKey: .companyId)
        try container.encode(campaigns, forKey: .campaigns)
        try container.encode(smartInd, forKey: .smartInd)
        try container.encode(accountInd, forKey: .accountInd)
        try container.encode(customerSegment, forKey: .customerSegment)
    }
}

