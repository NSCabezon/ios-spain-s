//
//  StandingOrderDataDTO.swift
//  SANPTLibrary
//
//  Created by Boris Chirino Fernandez on 13/7/21.
//

public enum StandingOrderPeriodicityType: String, Codable {
    case fixed = "fixed"
    case monthly = "monthly"
    case halfYear = "half_yearly"
    case weekly = "week"
    case annualy = "annual"
    case bimonth = "bimonthly"
    case none
}

public enum StandingOrderType: String, Codable {
    case recurrent = "recurrent"
    case standalone = "standalone"
}

public struct TransferAmountDTO: Codable {
    public let amount: Decimal?
    public let currency: String?
}

public struct StandingOrderDTO: Codable {
    public let accountId: String
    public let creditorName: String?
    public let paymentAmount: TransferAmountDTO?
    public let startDate: String?
    public let subject: String?
    public let periodicity: StandingOrderPeriodicityType?
    public let orderType: StandingOrderType?
    public let executedNumber: String?

    enum CodingKeys: String, CodingKey {
        case creditorName, paymentAmount, subject, executedNumber
        case accountId = "standingOrderAccountId"
        case periodicity = "standingOrderPeriod"
        case startDate = "standingOrderStartDate"
        case orderType = "standingOrderType"
    }
}

public struct StandingOrdersDataDTO: Codable {
    public let displayNumber: String
    public let accountInfo: StandingOrdersAccountInfoDTO
    public let orders: [StandingOrderDTO]
    public let page: PageDTO
    
    enum CodingKeys: String, CodingKey {
        case displayNumber
        case orders = "standingOrdersDataList"
        case page = "_links"
        case accountInfo = "standingOrdersAccountNumber"
    }
}

public struct StandingOrdersAccountInfoDTO: Codable {
    public let accountID, accountType: String

    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case accountType
    }
}
