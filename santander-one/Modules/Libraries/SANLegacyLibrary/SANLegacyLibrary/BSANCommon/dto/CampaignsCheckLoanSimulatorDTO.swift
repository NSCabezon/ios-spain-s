import SwiftyJSON

public struct CampaignsCheckLoanSimulatorDTO: Codable {
    public let proposalList: [LoanSimulatorProposalDTO]?
    public let client: LoanSimulatorClientDTO?
    public let structuralSegment: LoanSimulatorAlSegmentDTO?
    public let commercialSegment: LoanSimulatorAlSegmentDTO?
    public let center: LoanSimulatorCenterDTO?
    public let campaigns: [LoanSimulatorCampaignDTO]
    public let indAccount123: String
    public let indSmart: String
    public let amountSmart: String?
    public let employee: Bool
    
    public init?(json: JSON) {
        self.proposalList = CampaignsCheckLoanSimulatorDTO.parseProposalList(json: json)
        self.client = CampaignsCheckLoanSimulatorDTO.parseClient(json: json)
        self.structuralSegment = CampaignsCheckLoanSimulatorDTO.parseStructuralSegment(json: json)
        self.commercialSegment = CampaignsCheckLoanSimulatorDTO.parseCommercialSegment(json: json)
        self.center = CampaignsCheckLoanSimulatorDTO.parseCenter(json: json)
        self.campaigns = CampaignsCheckLoanSimulatorDTO.parseCampaigns(json: json) ?? []
        self.indAccount123 = json["indAccount123"].string ?? ""
        self.indSmart = json["indSmart"].string ?? ""
        self.amountSmart = json["amountSmart"].string
        self.employee = json["employee"].bool ?? false
    }
    
    private static func parseProposalList(json: JSON) -> [LoanSimulatorProposalDTO]? {
        let proposalListJSON = json["proposalList"]
        return proposalListJSON != JSON.null ? proposalListJSON.array?.map{ LoanSimulatorProposalDTO(json: $0) } : nil
    }
    
    private static func parseClient(json: JSON) -> LoanSimulatorClientDTO? {
        let clientJSON = json["client"]
        return clientJSON != JSON.null ? LoanSimulatorClientDTO(json: clientJSON) : nil
    }
    
    private static func parseStructuralSegment(json: JSON) -> LoanSimulatorAlSegmentDTO? {
        let structuralSegmentJSON = json["structuralSegment"]
        return structuralSegmentJSON != JSON.null ? LoanSimulatorAlSegmentDTO(json: structuralSegmentJSON) : nil
    }
    
    private static func parseCommercialSegment(json: JSON) -> LoanSimulatorAlSegmentDTO? {
        let commercialSegmentJSON = json["commercialSegment"]
        return commercialSegmentJSON != JSON.null ? LoanSimulatorAlSegmentDTO(json: commercialSegmentJSON) : nil
    }
    
    private static func parseCenter(json: JSON) -> LoanSimulatorCenterDTO? {
        let centerJSON = json["center"]
        return centerJSON != JSON.null ? LoanSimulatorCenterDTO(json: centerJSON) : nil
    }
    
    private static func parseCampaigns(json: JSON) -> [LoanSimulatorCampaignDTO]? {
        let campaignsJSON = json["campaigns"]
        return campaignsJSON != JSON.null ? campaignsJSON.array?.compactMap{ LoanSimulatorCampaignDTO(json: $0) } : nil
    }
}


public struct LoanSimulatorCampaignDTO: Codable {
    public let companyId: String?
    public let campaignCode: String
    public let familyCode: String
    public let maxAmount: Int
    public let currency: String
    public let campaignType: String?
    public let campaignDesc: String?
    public let multiplier: Int?
    public let campaignPurpose: String
    
    enum CodingKeys: String, CodingKey {
        case companyId = "companyId"
        case campaignCode = "campaignCode"
        case familyCode = "familyCode"
        case maxAmount = "maxAmount"
        case currency = "currency"
        case campaignType = "campaignType"
        case campaignDesc = "campaignDesc"
        case multiplier = "multiplier"
        case campaignPurpose = "campaignPurpose"
    }
    
    public init?(json: JSON) {
        guard let campaignCode = json["campaignCode"].string,
            let familiyCode = json["familyCode"].string,
        let maxAmount = json["maxAmount"].int,
        let campaignPurpose = json["campaignPurpose"].string,
        let currency = json["currency"].string
        else { return nil }
        
        self.campaignPurpose = campaignPurpose
        self.campaignCode = campaignCode
        self.familyCode = familiyCode
        self.maxAmount = maxAmount
        self.currency = currency
        self.companyId = json["companyId"].string
        self.campaignType = json["campaignType"].string
        self.campaignDesc = json["campaignDesc"].string
        self.multiplier = json["multiplier"].int
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.companyId = try container.decodeIfPresent(String.self, forKey: .companyId)
        self.campaignCode = try container.decode(String.self, forKey: .campaignCode)
        self.familyCode = try container.decode(String.self, forKey: .familyCode)
        self.maxAmount = try container.decode(Int.self, forKey: .maxAmount)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.campaignType = try container.decodeIfPresent(String.self, forKey: .campaignType)
        self.campaignDesc = try container.decodeIfPresent(String.self, forKey: .campaignDesc)
        self.multiplier = try container.decodeIfPresent(Int.self, forKey: .multiplier)
        self.campaignPurpose = try container.decode(String.self, forKey: .campaignPurpose)
    }
     
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(companyId, forKey: .companyId)
        try container.encode(campaignCode, forKey: .campaignCode)
        try container.encode(familyCode, forKey: .familyCode)
        try container.encode(maxAmount, forKey: .maxAmount)
        try container.encodeIfPresent(campaignType, forKey: .campaignType)
        try container.encodeIfPresent(campaignDesc, forKey: .campaignDesc)
        try container.encodeIfPresent(multiplier, forKey: .multiplier)
        try container.encode(campaignPurpose, forKey: .campaignPurpose)
    }
}


public struct LoanSimulatorCenterDTO: Codable, RestParser {
    public let company: String?
    public let center: String?
    
    public init(json: JSON) {
        self.company = json["company"].string
        self.center = json["center"].string
    }
}


public struct LoanSimulatorClientDTO: Codable {
    public let personType: String?
    public let personCode: Int?
    
    public init(json: JSON) {
        self.personType = json["personType"].string
        self.personCode = json["personCode"].int
    }
}

public struct LoanSimulatorAlSegmentDTO: Codable, RestParser {
    public let companyId: String?
    public let segment: String?
    
    public init(json: JSON) {
        self.companyId = json["companyId"].string
        self.segment = json["segment"].string
    }
}


public struct LoanSimulatorProposalDTO: Codable, RestParser {
    public let proposalCode: LoanSimulatorProposalCodeDTO?
    public let product: LoanSimulatorProductDTO?
    public let amount: Int?
    public let currency: String?
    public let term: Int?
    public let interestType: Double?
    public let tae: Double?
    public let status: String?
    public let phase: LoanSimulatorPhaseDTO?
    public let f2Code: String?
    
    public init(json: JSON) {
        self.proposalCode = LoanSimulatorProposalDTO.parseProposalCode(json: json)
        self.product = LoanSimulatorProposalDTO.parseProduct(json: json)
        self.amount = json["amount"].int
        self.currency = json["currency"].string
        self.term = json["term"].int
        self.interestType = json["interestType"].double
        self.tae = json["tae"].double
        self.status = json["status"].string
        self.phase = LoanSimulatorProposalDTO.parsePhase(json: json)
        self.f2Code = json["f2Code"].string
    }
    
    private static func parseProposalCode(json: JSON) -> LoanSimulatorProposalCodeDTO? {
        let proposalCodeJSON = json["proposalCode"]
        return proposalCodeJSON != JSON.null ? LoanSimulatorProposalCodeDTO(json: proposalCodeJSON) : nil
    }
    
    private static func parseProduct(json: JSON) -> LoanSimulatorProductDTO? {
        let productJSON = json["product"]
        return productJSON != JSON.null ? LoanSimulatorProductDTO(json: productJSON) : nil
    }
    
    private static func parsePhase(json: JSON) -> LoanSimulatorPhaseDTO? {
        let phaseJSON = json["phase"]
        return phaseJSON != JSON.null ? LoanSimulatorPhaseDTO(json: phaseJSON) : nil
    }
}


public struct LoanSimulatorPhaseDTO: Codable, RestParser {
    public let code: String?
    public let descriptionPhase: String?
    
    public init(json: JSON) {
        self.code = json["code"].string
        self.descriptionPhase = json["descriptionPhase"].string
    }
}


public struct LoanSimulatorProductDTO: Codable, RestParser {
    public let productCode: String?
    public let productSubType: String?
    public let productCompany: String?
    public let precoFlag: Bool?
    
    public init(json: JSON) {
        self.productCode = json["productCode"].string
        self.productSubType = json["productSubType"].string
        self.productCompany = json["productCompany"].string
        self.precoFlag = json["precoFlag"].bool
    }
}


public struct LoanSimulatorProposalCodeDTO: Codable, RestParser {
    public let companyId: String?
    public let centerId: String?
    public let proposalYear: String?
    public let proposalId: Int?
    
    public init(json: JSON) {
        self.companyId = json["companyId"].string
        self.centerId = json["centerId"].string
        self.proposalYear = json["proposalYear"].string
        self.proposalId = json["proposalId"].int
    }
}

