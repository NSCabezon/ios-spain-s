//
//  FintechTicketContainerView.swift
//  Ecommerce
//
//  Created by alvola on 16/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

class FintechTicketContainerView: UIView {

    lazy var ticketView: EcommerceTicketView = {
        let imageView = EcommerceTicketView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = AccessibilityFintechTicketView.ticket
        addSubview(imageView)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

private extension FintechTicketContainerView {
    func setup() {
        NSLayoutConstraint.activate([ticketView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 43.0),
                                     self.trailingAnchor.constraint(equalTo: ticketView.trailingAnchor, constant: 43.0),
                                     ticketView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
                                     ticketView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100.0)])
        ticketView.drawShadow(offset: (0, 3),
                              opacity: 0.5,
                              color: .gray,
                              radius: 4)
    }
}
