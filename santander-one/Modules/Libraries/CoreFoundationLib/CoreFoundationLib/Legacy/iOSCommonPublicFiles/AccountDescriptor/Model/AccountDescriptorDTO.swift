import Foundation

public struct AccountDescriptorDTO: Codable {
    public let type: String?
    public let subType: String?
    
    public init(type: String? = nil, subType: String? = nil) {
        self.type = type
        self.subType = subType
    }
}

public struct AccountDescriptorArrayDTO {
    public var accountsArray: [AccountDescriptorDTO]
    public var iberiaIconCardsArray: [AccountDescriptorDTO]
    public var plansArray: [ProductAllianzDTO]
    public var cardsTextColor: [CardTextColorDTO]
    public var chatProducts: [ProductRangeDescriptorDTO]
    public var securityOneProducts: [ProductRangeDescriptorDTO]
    public var paymentOneProducts: [ProductRangeDescriptorDTO]
    public var vipOneProducts: [ProductRangeDescriptorDTO]
    public var safeOneProducts: [ProductRangeDescriptorDTO]
    public var accountGroupEntities: [GroupEntityDTO]
    public let appIcons: [AppIconDTO]
    public let xmlString: String
    
    @available(*, deprecated, message: "init(accountsArray: [AccountDescriptorDTO], plansArray: [ProductAllianzDTO], cardsColorDTO: [CardTextColorDTO], chatProducts: [ProductRangeDescriptorDTO], securityOneProducts: [ProductRangeDescriptorDTO], paymentOneProducts: [ProductRangeDescriptorDTO], vipOneProducts: [ProductRangeDescriptorDTO], safeOneProducts: [ProductRangeDescriptorDTO], accountGroupEntities: [GroupEntityDTO], appIcons: [AppIconDTO], xmlString: String)")
    public init(accountsArray: [AccountDescriptorDTO], iberiaIconCardsArray: [AccountDescriptorDTO],  plansArray: [ProductAllianzDTO], cardsColorDTO: [CardTextColorDTO], chatProducts: [ProductRangeDescriptorDTO], securityOneProducts: [ProductRangeDescriptorDTO], paymentOneProducts: [ProductRangeDescriptorDTO], vipOneProducts: [ProductRangeDescriptorDTO], accountGroupEntities: [GroupEntityDTO], appIcons: [AppIconDTO], xmlString: String) {
        self.accountsArray = accountsArray
        self.iberiaIconCardsArray = iberiaIconCardsArray
        self.plansArray = plansArray
        self.cardsTextColor = cardsColorDTO
        self.chatProducts = chatProducts
        self.securityOneProducts = securityOneProducts
        self.paymentOneProducts = paymentOneProducts
        self.vipOneProducts = vipOneProducts
        self.safeOneProducts = []
        self.accountGroupEntities = accountGroupEntities
        self.appIcons = appIcons
        self.xmlString = xmlString
    }
    public init(accountsArray: [AccountDescriptorDTO], iberiaIconCardsArray: [AccountDescriptorDTO], plansArray: [ProductAllianzDTO], cardsColorDTO: [CardTextColorDTO], chatProducts: [ProductRangeDescriptorDTO], securityOneProducts: [ProductRangeDescriptorDTO], paymentOneProducts: [ProductRangeDescriptorDTO], vipOneProducts: [ProductRangeDescriptorDTO], safeOneProducts: [ProductRangeDescriptorDTO], accountGroupEntities: [GroupEntityDTO], appIcons: [AppIconDTO], xmlString: String) {
        self.accountsArray = accountsArray
        self.iberiaIconCardsArray = iberiaIconCardsArray
        self.plansArray = plansArray
        self.cardsTextColor = cardsColorDTO
        self.chatProducts = chatProducts
        self.securityOneProducts = securityOneProducts
        self.paymentOneProducts = paymentOneProducts
        self.vipOneProducts = vipOneProducts
        self.safeOneProducts = safeOneProducts
        self.accountGroupEntities = accountGroupEntities
        self.appIcons = appIcons
        self.xmlString = xmlString
    }
    
}
