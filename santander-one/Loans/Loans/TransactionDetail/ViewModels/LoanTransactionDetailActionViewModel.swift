//
//  LoanTransactionDetailActionViewModel.swift
//  Loans
//
//  Created by Ernesto Fernandez Calles on 27/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import UI

struct LoanTransactionDetailActionViewModel {
    let type: LoanTransactionDetailActionType
    public let viewType: ActionButtonFillViewType
    public let action: ((LoanTransactionDetailActionType, LoanEntity) -> Void)?
    public let isDisabled: Bool
    public let entity: LoanEntity
    public let highlightedInfo: HighlightedInfo?
    public let isUserInteractionEnable: Bool
    public let isDragDisabled: Bool
    public let renderingMode: UIImage.RenderingMode
    
    public init(entity: LoanEntity,
                type: LoanTransactionDetailActionType,
                viewType: ActionButtonFillViewType? = nil,
                action: ((LoanTransactionDetailActionType, LoanEntity) -> Void)?,
                isDisabled: Bool = false,
                highlightedInfo: HighlightedInfo? = nil,
                isUserInteractionEnable: Bool = true,
                isDragDisabled: Bool = false,
                renderingMode: UIImage.RenderingMode = .alwaysTemplate) {
        self.entity = entity
        self.type = type
        self.viewType = viewType ?? type.getViewType(renderingMode)
        self.action = action
        self.highlightedInfo = highlightedInfo
        self.isDisabled = isDisabled
        self.isUserInteractionEnable = isUserInteractionEnable
        self.isDragDisabled = isDragDisabled
        self.renderingMode = renderingMode
    }
    
    func copyViewModel(entity: LoanEntity? = nil,
                       type: LoanTransactionDetailActionType? = nil,
                       viewType: ActionButtonFillViewType? = nil,
                       action: ((LoanTransactionDetailActionType, LoanEntity) -> Void)? = nil,
                       isDisabled: Bool? = nil,
                       highlightedInfo: HighlightedInfo? = nil,
                       isUserInteractionEnable: Bool? = nil,
                       isDragDisabled: Bool? = nil,
                       renderingMode: UIImage.RenderingMode? = nil) -> LoanTransactionDetailActionViewModel {
        return LoanTransactionDetailActionViewModel(
            entity: entity ?? self.entity,
            type: type ?? self.type,
            viewType: viewType ?? self.viewType,
            action: action ?? self.action,
            isDisabled: isDisabled ?? self.isDisabled,
            highlightedInfo: highlightedInfo ?? self.highlightedInfo,
            isUserInteractionEnable: isUserInteractionEnable ?? self.isUserInteractionEnable,
            isDragDisabled: isDragDisabled ?? self.isDragDisabled,
            renderingMode: renderingMode ?? self.renderingMode
        )
    }
}

extension LoanTransactionDetailActionViewModel: ActionButtonViewModelProtocol {
    public var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }

    public var actionType: LoanTransactionDetailActionType {
        return type
    }
}

extension LoanTransactionDetailActionViewModel: Equatable {
    public static func == (lhs: LoanTransactionDetailActionViewModel, rhs: LoanTransactionDetailActionViewModel) -> Bool {
        return lhs.viewType == rhs.viewType
    }
}
