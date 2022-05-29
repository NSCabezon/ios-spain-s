public class PGUserPrefDTO: Codable {
    public var chatModule = PGModuleDTO()
    public var yourMoneyModule = PGModuleDTO()
    public var pfmModule = PGModuleDTO()
    
    public var accountsBox = PGBoxDTO()
    public var cardsBox = PGBoxDTO()
    public var loansBox = PGBoxDTO()
    public var depositsBox = PGBoxDTO()
    public var stocksBox = PGBoxDTO()
    public var fundssBox = PGBoxDTO()
    public var pensionssBox = PGBoxDTO()
    public var portfolioManagedsBox = PGBoxDTO()
    public var portfolioNotManagedsBox = PGBoxDTO()
    public var insuranceSavingsBox = PGBoxDTO()
    public var insuranceProtectionsBox = PGBoxDTO()
    public var portfolioManagedVariableIncomesBox = PGBoxDTO()
    public var portfolioNotManagedVariableIncomesBox = PGBoxDTO()
    public var onboardingDisabled: Bool = false
    public var onboardingFinished: Bool = false
    public var otpPushBetaFinished: Bool = false
    public var globalPositionOptionSelected: Int = 0
    public var photoThemeOptionSelected: Int?
    
    init() {}
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chatModule = try container.decode(PGModuleDTO.self, forKey: .chatModule)
        yourMoneyModule = try container.decode(PGModuleDTO.self, forKey: .yourMoneyModule)
        pfmModule = try container.decode(PGModuleDTO.self, forKey: .pfmModule)
        accountsBox = try container.decode(PGBoxDTO.self, forKey: .accountsBox)
        cardsBox = try container.decode(PGBoxDTO.self, forKey: .cardsBox)
        loansBox = try container.decode(PGBoxDTO.self, forKey: .loansBox)
        depositsBox = try container.decode(PGBoxDTO.self, forKey: .depositsBox)
        stocksBox = try container.decode(PGBoxDTO.self, forKey: .stocksBox)
        fundssBox = try container.decode(PGBoxDTO.self, forKey: .fundssBox)
        pensionssBox = try container.decode(PGBoxDTO.self, forKey: .pensionssBox)
        portfolioManagedsBox = try container.decode(PGBoxDTO.self, forKey: .portfolioManagedsBox)
        portfolioNotManagedsBox = try container.decode(PGBoxDTO.self, forKey: .portfolioNotManagedsBox)
        insuranceSavingsBox = try container.decode(PGBoxDTO.self, forKey: .insuranceSavingsBox)
        insuranceProtectionsBox = try container.decode(PGBoxDTO.self, forKey: .insuranceProtectionsBox)
        portfolioManagedVariableIncomesBox = try container.decode(PGBoxDTO.self, forKey: .portfolioManagedVariableIncomesBox)
        portfolioNotManagedVariableIncomesBox = try container.decode(PGBoxDTO.self, forKey: .portfolioNotManagedVariableIncomesBox)
        onboardingDisabled = try container.decodeIfPresent(Bool.self, forKey: .onboardingDisabled) ?? false
        onboardingFinished = try container.decodeIfPresent(Bool.self, forKey: .onboardingFinished) ?? false
        otpPushBetaFinished = try container.decodeIfPresent(Bool.self, forKey: .otpPushBetaFinished) ?? false
        globalPositionOptionSelected = try container.decodeIfPresent(Int.self, forKey: .globalPositionOptionSelected) ?? 0
        photoThemeOptionSelected = try container.decodeIfPresent(Int.self, forKey: .photoThemeOptionSelected)
    }
}

// MARK: Codable
extension PGUserPrefDTO {
    public enum CodingKeys: String, CodingKey {
        case chatModule
        case yourMoneyModule
        case pfmModule
        case accountsBox
        case cardsBox
        case loansBox
        case depositsBox
        case stocksBox
        case fundssBox
        case pensionssBox
        case portfolioManagedsBox
        case portfolioNotManagedsBox
        case insuranceSavingsBox
        case insuranceProtectionsBox
        case portfolioManagedVariableIncomesBox
        case portfolioNotManagedVariableIncomesBox
        case onboardingDisabled
        case onboardingFinished
        case otpPushBetaFinished
        case globalPositionOptionSelected
        case photoThemeOptionSelected
    }
}
