//

import Foundation
import CoreFoundationLib

class PaymentMethodSubtypeViewModel: TableModelViewItem<PaymentMethodSubtypeCell> {
    
    private let title: Int
    private let subtitle: Int?
    private let isSelected: Bool
    private let status: PaymentMethodStatus
    
    //! title: amount, title and subtitle when percentage and amount
    init(_ title: Int, subtitle: Int? = nil, status: PaymentMethodStatus, isSelected: Bool, dependencies: PresentationComponent) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.isSelected = isSelected
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: PaymentMethodSubtypeCell) {
        viewCell.subtypeLocalizedStylableText = formatByStatus(status: status)
        viewCell.selected(isSelected)
        viewCell.setAccessibilityIdentifiers(identifier: "\(status.rawValue)_subtype")
    }
    
    private func formatByStatus(status: PaymentMethodStatus) -> LocalizedStylableText {
        var result = LocalizedStylableText.empty
        if status == .fixedFee {
            result = dependencies.stringLoader.getString("changeWayToPay_label_fixedFeeNumValue", [StringPlaceholder(.value, String(title))])
        } else if status == .deferredPayment {
            result = dependencies.stringLoader.getString("changeWayToPay_label_postponeNumValue",
                                                         [StringPlaceholder(StringPlaceholder.Placeholder.number, formatterForRepresentation(.decimal(decimals: 0)).string(from: NSNumber(value: title)) ?? ""),
                                                 StringPlaceholder(StringPlaceholder.Placeholder.value, String(subtitle ?? 0))])
        }
        return result
    }
}
