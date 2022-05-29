//
//  LoanTransactionDetailAction.swift
//  Loans
//
//  Created by alvola on 28/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI

struct LoanTransactionDetailAction {
    let type: LoanTransactionDetailActionType
    let viewType: ActionButtonFillViewType
    let action: ((LoanTransactionDetailActionType, LoanRepresentable) -> Void)? = nil
    let isDisabled: Bool
    let entity: LoanRepresentable
    let highlightedInfo: HighlightedInfo?
    let isUserInteractionEnable: Bool
    let isDragDisabled: Bool
    let renderingMode: UIImage.RenderingMode
    
    init(representable: LoanRepresentable,
         type: LoanTransactionDetailActionType,
         viewType: ActionButtonFillViewType? = nil,
         isDisabled: Bool = false,
         highlightedInfo: HighlightedInfo? = nil,
         isUserInteractionEnable: Bool = true,
         isDragDisabled: Bool = false,
         renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.entity = representable
        self.type = type
        self.viewType = viewType ?? type.getViewType(renderingMode)
        self.highlightedInfo = highlightedInfo
        self.isDisabled = isDisabled
        self.isUserInteractionEnable = isUserInteractionEnable
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
}

extension LoanTransactionDetailAction: ActionButtonViewModelProtocol {
    public var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }

    public var actionType: LoanTransactionDetailActionType {
        return type
    }
}

extension LoanTransactionDetailAction: Equatable {
    public static func == (lhs: LoanTransactionDetailAction, rhs: LoanTransactionDetailAction) -> Bool {
        return lhs.viewType == rhs.viewType
    }
}

struct LoanActionAccessibilityIds {
    let container: String?
    let icon: String?
    let title: String?
}
