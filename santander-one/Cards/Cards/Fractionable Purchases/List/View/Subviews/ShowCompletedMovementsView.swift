//
//  ShowCompletedMovementsView.swift
//  Cards
//
//  Created by alvola on 16/02/2021.
//

import UIKit
import CoreFoundationLib
import UI

final class ShowCompletedMovementsView: UIView {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "fractionatePurchasesBtnSeeFinished"
        view.backgroundColor = .clear
        addSubview(view)
        return view
    }()
    
    private lazy var showLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 16.0)
        label.textColor = .darkTorquoise
        label.textAlignment = .center
        label.accessibilityIdentifier = "fractionatePurchases_button_seeFinished"
        label.text = localized("fractionatePurchases_button_seeFinished")
        containerView.addSubview(label)
        return label
    }()
    
    private lazy var arrowImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnArrowDownGr"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.accessibilityIdentifier = "icnArrowDown"
        containerView.addSubview(image)
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func isOpen(_ open: Bool) {
        let rotation = open ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.arrowImage.transform = rotation
        }
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        showLabel.configureText(withLocalizedString: title)
    }
}

private extension ShowCompletedMovementsView {
    func commonInit() {
        configureView()
        configureShowLabelConstraints()
        configureArrowImageConstraints()
        configureAmountLabelConstraints()
    }
    
    func configureView() {
        backgroundColor = .clear
        accessibilityIdentifier = "fractionatePurchasesBtnSeeFinished"
        heightAnchor.constraint(equalToConstant: 41.0).isActive = true
    }
    
    func configureShowLabelConstraints() {
        NSLayoutConstraint.activate([
            showLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            showLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            showLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            showLabel.heightAnchor.constraint(equalToConstant: 23.0)
        ])
    }
    
    func configureArrowImageConstraints() {
        NSLayoutConstraint.activate([
            arrowImage.leadingAnchor.constraint(equalTo: showLabel.trailingAnchor, constant: 5.0),
            containerView.trailingAnchor.constraint(greaterThanOrEqualTo: arrowImage.trailingAnchor),
            arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 2.0),
            arrowImage.heightAnchor.constraint(equalToConstant: 14.0),
            arrowImage.widthAnchor.constraint(equalToConstant: 14.0)
        ])
    }
    
    func configureAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
