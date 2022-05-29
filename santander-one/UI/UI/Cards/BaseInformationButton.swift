//
//  CardInformationViewProtocol.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 08/05/2020.
//

import Foundation

public protocol InformationButtonConformable: AnyObject {
    var viewAlpha: CGFloat { get}
    func setDisabled(_ disabled: Bool)
}

extension InformationButtonConformable {
    public var viewAlpha: CGFloat {
        0.4
    }
}
/// All information buttons for cards home must be child of this class in order to set disabled, if is not possible inheritance use composition making class conforming to InformationButtonConformable protocol, example ChangePaymentMethodButtonView, its child of XibView. Multiple inheritance is not allowed so this class must conform manually InformationButtonConformable.
open class BaseInformationButton: XibView {}

extension BaseInformationButton: InformationButtonConformable {
    public func setDisabled(_ disabled: Bool) {
        if disabled {
            self.isUserInteractionEnabled = false
            self.alpha = self.viewAlpha
        }
    }
}
