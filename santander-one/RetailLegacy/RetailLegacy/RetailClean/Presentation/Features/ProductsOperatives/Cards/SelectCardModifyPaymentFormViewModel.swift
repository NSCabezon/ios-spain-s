import UIKit
import UI

class SelectCardModifyPaymentFormViewModel: RadioSubtitleTableModelView {
    let title: LocalizedStylableText
    let isVisibleSubtitleSection: Bool
    var suffixIdentifier: String
    
    init?(inputIdentifier: String, payment: PaymentMethod, radio: RadioSubtitleTable, subtitle: LocalizedStylableText? = nil, isInitialIndex: Bool, privateComponent: PresentationComponent) {
        let tag: Int
        switch payment.paymentMethod {
        case .monthlyPayment?:
            tag = 0
            title = privateComponent.stringLoader.getString("changeWayToPay_label_monthly")
            isVisibleSubtitleSection = false
            self.suffixIdentifier = "_monthly"
        case .deferredPayment?:
            tag = 1
            title = privateComponent.stringLoader.getString("changeWayToPay_label_postpone")
            isVisibleSubtitleSection = true
            self.suffixIdentifier = "_postpone"
        case .fixedFee?:
            tag = 2
            title = privateComponent.stringLoader.getString("changeWayToPay_label_fixedFee")
            isVisibleSubtitleSection = true
            self.suffixIdentifier = "_fixedFee"
        default:
            return nil
        }
        let info = RadioSubtitleTableInfo(title: title,
                                          subtitle: subtitle,
                                          view: nil,
                                          insets: UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 13),
                                          height: 50,
                                          auxiliaryImage: Assets.image(named: "icnInfoGrayBig"),
                                          auxiliaryTag: tag,
                                          isInitialIndex: isInitialIndex,
                                          isVisibleSubtitleSection: isVisibleSubtitleSection)
        super.init(inputIdentifier: "\(inputIdentifier)\(suffixIdentifier)", info: info, radioTable: radio, privateComponent)
    }
}
