//
//  EcommerceTicketErrorView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 3/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceTicketErrorView: XibView {
    
    @IBOutlet private weak var errorView: PurchaseStatusView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func updateError(reason: String) {
        self.errorView.configView(.errorData(reason: reason))
    }
}

private extension EcommerceTicketErrorView {
    func setupView() {
        self.backgroundColor = .clear
        self.errorView.configView(.errorData(reason: nil))
        self.setAccessibilityIds()
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommercePurchaseStatusView.errorView
    }
}
