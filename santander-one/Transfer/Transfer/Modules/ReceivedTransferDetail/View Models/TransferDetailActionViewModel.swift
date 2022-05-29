import Foundation
import CoreFoundationLib

public struct TransferDetailActionViewModel: ActionButtonFillViewModelProtocol {
    public let viewType: ActionButtonFillViewType
    
    let highlightedInfo: HighlightedInfo?
    let action: () -> Void
    let accessibilityIdentifier: String
    
    init(type: ActionButtonFillViewType? = nil,
         title: String,
         imageNamed: String,
         highlightedInfo: HighlightedInfo? = nil,
         action: @escaping () -> Void,
         accessibilityIdentifier: String) {
        let viewType: ActionButtonFillViewType = type ?? .defaultButton(DefaultActionButtonViewModel(
            title: title,
            imageKey: imageNamed,
            titleAccessibilityIdentifier: title,
            imageAccessibilityIdentifier: imageNamed
        ))
        self.viewType = viewType
        self.highlightedInfo = highlightedInfo
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}
