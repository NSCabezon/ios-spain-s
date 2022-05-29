//

import Foundation
import CoreFoundationLib

struct PaymentMethodDescription {
    let dependencies: PresentationComponent
    let paymentMethodStatus: PaymentMethodStatus
    let title: Int
    let subtitle: Int?
    
    func paymentMethodDescription() -> String? {
        switch paymentMethodStatus {
        case .monthlyPayment:
            return dependencies.stringLoader.getString("changeWayToPay_label_monthly").text
        case .fixedFee:
            return dependencies.stringLoader.getString("changeWayToPay_label_fixedFeeValue", [StringPlaceholder(.value, String(title))]).text
        case .deferredPayment:
            return dependencies.stringLoader.getString("changeWayToPay_label_postponeValue",
                                                       [StringPlaceholder(StringPlaceholder.Placeholder.number, formatterForRepresentation(.decimal(decimals: 0)).string(from: NSNumber(value: title)) ?? ""),
                                                 StringPlaceholder(StringPlaceholder.Placeholder.value, String(subtitle ?? 0))]).text
        default:
            return nil
        }
    }
}
