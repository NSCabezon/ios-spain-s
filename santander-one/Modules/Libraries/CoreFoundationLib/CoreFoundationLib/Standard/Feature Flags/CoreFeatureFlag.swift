//
//  CoreFeatureFlag.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreDomain

public enum CoreFeatureFlag: String, CaseIterable {
    case internalTransfer
    case domesticSendMoney
    case internationalSendMoney
    case cardTransactionFilters
    case oneFavoriteList
    case cardTransactionDetail
    case transferHome
}

extension CoreFeatureFlag: FeatureFlagRepresentable {
    public var identifier: String {
        return rawValue
    }
    
    public var description: String {
        switch self {
        case .internalTransfer: return "Internal Transfer"
        case .domesticSendMoney: return "Send money domestic"
        case .internationalSendMoney: return "Send money international"
        case .cardTransactionFilters: return "Card transaction filters"
        case .oneFavoriteList: return "Favorite list in One Home"
        case .cardTransactionDetail: return "Card Transaction Detail"
        case .transferHome: return "Transfer home"
        }
    }
    
    public var defaultValue: FeatureValue {
        switch self {
        case .internalTransfer: return .boolean(false)
        default:
            return .boolean(false)
        }
    }
}
