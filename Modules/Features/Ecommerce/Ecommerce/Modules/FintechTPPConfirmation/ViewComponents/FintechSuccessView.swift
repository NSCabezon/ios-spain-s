//
//  FintechSuccessView.swift
//  Ecommerce
//
//  Created by alvola on 19/04/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

final class FintechSuccessView: FintechTicketContainerView {

    private lazy var image: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnSantanderKeyOkLock"))
        image.translatesAutoresizingMaskIntoConstraints = false
        ticketView.addSubview(image)
        return image
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(family: .headline, type: .bold, size: 20.0)
        label.textColor = .lisboaGray
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = localized("ecommerce_label_identification")
        ticketView.addSubview(label)
        return label
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

private extension FintechSuccessView {
    func setup() {
        configureImageConstraints()
        configureLabelConstraints()
        setAccessibilityIdentifiers()
    }
    
    func configureImageConstraints() {
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: ticketView.centerXAnchor),
            image.topAnchor.constraint(equalTo: ticketView.topAnchor, constant: 77.0),
            image.heightAnchor.constraint(equalToConstant: 64.0),
            image.widthAnchor.constraint(equalToConstant: 70.0)
        ])
    }
    
    func configureLabelConstraints() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: ticketView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: ticketView.leadingAnchor, constant: 12.0),
            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 7.0),
            ticketView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 118.0)
        ])
    }
    
    func setAccessibilityIdentifiers() {
        image.accessibilityIdentifier = AccessibilityFintechSuccessView.icon
        label.accessibilityIdentifier = AccessibilityFintechSuccessView.identificationLabel
    }
}
