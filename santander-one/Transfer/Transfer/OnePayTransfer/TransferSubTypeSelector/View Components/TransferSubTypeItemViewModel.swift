//
//  TransferSubTypeItemViewModel.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 31/01/2020.
//

import Foundation
import CoreFoundationLib

public struct TransferSubTypeItemViewModel {
    
    public let typeValue: TransferSubType
    let description: String
    let info: LocalizedStylableText
    let commission: String
    var type: String {
        return self.typeValue.description
    }
    let commissionDescription: String
    public let isSelected: Bool
    public let commissionEntity: AmountEntity?
    
    public init(type: TransferSubType, localizedInfo: LocalizedStylableText, description: String, commission: AmountEntity?, isSelected: Bool, commissionDescription: String) {
        self.typeValue = type
        self.info = localizedInfo
        self.description = description
        self.commission = commission?.getFormattedAmountAsMillions() ?? ""
        self.isSelected = isSelected
        self.commissionDescription = commissionDescription
        self.commissionEntity = commission
    }
    
    public init(type: TransferSubType, info: String, description: String, commission: AmountEntity?, isSelected: Bool, commissionDescription: String) {
        self.typeValue = type
        self.info = localized(info)
        self.description = description
        self.commission = commission?.getFormattedAmountAsMillions() ?? ""
        self.isSelected = isSelected
        self.commissionDescription = commissionDescription
        self.commissionEntity = commission
    }
    
    public init(from otherViewModel: TransferSubTypeItemViewModel, isSelected: Bool) {
        self.typeValue = otherViewModel.typeValue
        self.info = otherViewModel.info
        self.description = otherViewModel.description
        self.commission = otherViewModel.commission
        self.isSelected = isSelected
        self.commissionDescription = otherViewModel.commissionDescription
        self.commissionEntity = otherViewModel.commissionEntity
    }
    
    var typeAccessibilityId: String {
        switch typeValue {
        case .instant: return AccessibilityTransferSelector.areaInmediate.rawValue
        case .standard: return AccessibilityTransferSelector.areaStandar.rawValue
        case .urgent: return AccessibilityTransferSelector.areaExpress.rawValue
        }
    }
}

extension TransferSubTypeItemViewModel: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension TransferSubTypeItemViewModel: Equatable {
    
    public static func == (lhs: TransferSubTypeItemViewModel, rhs: TransferSubTypeItemViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
