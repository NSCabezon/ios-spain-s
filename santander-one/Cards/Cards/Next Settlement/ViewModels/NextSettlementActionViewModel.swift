//
//  NextSettlementActionViewModel.swift
//  Cards
//
//  Created by Laura González on 08/10/2020.
//

import Foundation
import CoreFoundationLib
import UI

public enum NextSettlementActionType {
    case postponeReceipt
    case changePaymentMethod
    case historicExtractPDF
    case shoppingMap
    
    func values() -> (title: String, imageName: String) {
        switch self {
        case .postponeReceipt: return ("cardsOption_button_delayPayment", "icnDelayReceipt")
        case .changePaymentMethod: return ("cardsOption_button_changePaymentMethod", "icnChangeWayToPay")
        case .historicExtractPDF: return ("cardsOption_button_statementHistory", "icnStatementHistory")
        case .shoppingMap: return ("cardsOption_button_purchaseMap", "icnPurchaseMap")
        }
    }
    
    func getViewType() -> ActionButtonFillViewType {
        let optionValues = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           titleAccessibilityIdentifier: optionValues.title,
                                                           imageAccessibilityIdentifier: optionValues.imageName))
    }
}

extension NextSettlementActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .postponeReceipt:
            return AccessibilityCardsNextSettlementDetail.nextSettlementBtnDelayPayment.rawValue
        case .changePaymentMethod:
            return AccessibilityCardsNextSettlementDetail.nextSettlementBtnChangeWayToPay.rawValue
        case .historicExtractPDF:
            return AccessibilityCardsNextSettlementDetail.nextSettlementBtnStatement.rawValue
        case .shoppingMap:
            return AccessibilityCardsNextSettlementDetail.nextSettlementBtnPurchaseMap.rawValue
        }
    }
}

extension NextSettlementActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .postponeReceipt:
            return "aplazar_recibo"
        case .changePaymentMethod:
            return "cambiar_forma_pago"
        case .historicExtractPDF:
            return "extracto_pdf"
        case .shoppingMap:
            return "mapa_compras"
        }
    }
}

struct NextSettlementActionViewModel {
    let type: NextSettlementActionType
    let viewType: ActionButtonFillViewType
    let entity: CardEntity
    let isDisabled: Bool
    let highlightedInfo: HighlightedInfo?
    let action: ((NextSettlementActionType, CardEntity) -> Void)?
    let isDragDisabled: Bool
    let renderingMode: UIImage.RenderingMode
    let isRemarkable: Bool
    var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }
    
    init(type: NextSettlementActionType,
         entity: CardEntity,
         isDisabled: Bool = false,
         imageUrl: String? = nil,
         highlightedInfo: HighlightedInfo? = nil,
         action: ((NextSettlementActionType, CardEntity) -> Void)?,
         isDragDisabled: Bool = false,
         renderingMode: UIImage.RenderingMode = .alwaysTemplate,
         isRemarkable: Bool = false) {
        self.type = type
        self.viewType = type.getViewType()
        self.entity = entity
        self.isDisabled = isDisabled
        self.highlightedInfo = highlightedInfo
        self.action = action
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
        self.isRemarkable = isRemarkable
    }
}

extension NextSettlementActionViewModel: ActionButtonViewModelProtocol {
    var actionType: NextSettlementActionType {
        return type
    }
}
