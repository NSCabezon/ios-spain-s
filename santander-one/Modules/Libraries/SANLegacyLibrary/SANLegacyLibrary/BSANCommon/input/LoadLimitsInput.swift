public struct LoanSimulatorDataSend {
    public let term: Int
    public let amount: Int
    
    public init(term: Int, amount: Int) {
        self.term = term
        self.amount = amount
    }
}

public struct LoadLimitsInput {
    
    public let employee: Bool
    public let group: String
    public let campaigns: [LoanSimulatorCampaignDTO]
    public let smartInd: String
    public let accountInd: String
    public let customerSegment: String
    
    public init(employee: Bool, group: String, campaigns: [LoanSimulatorCampaignDTO], smartInd: String, accountInd: String, customerSegment: String = "PR") {
        self.employee = employee
        self.group = group
        self.campaigns = campaigns
        self.smartInd = smartInd
        self.accountInd = accountInd
        self.customerSegment = customerSegment
    }
    
}
