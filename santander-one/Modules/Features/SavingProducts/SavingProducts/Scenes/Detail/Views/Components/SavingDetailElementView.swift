//
//  SavingDetailElementView.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import UIOneComponents

final class SavingDetailElementView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var titleLabel: UILabel = UILabel()
    var valueLabel: UILabel = UILabel()
    var iconView = UIImageView()
    let onTouchIconSubject = PassthroughSubject<Void, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    func configure(title: String,
                   value: String,
                   icon: UIImage?,
                   titleIdentifier: String,
                   valueIdentifier: String,
                   iconIdentifier: String?) {
        self.titleLabel.text = title
        self.valueLabel.text = value
        self.titleLabel.accessibilityIdentifier = titleIdentifier
        self.valueLabel.accessibilityIdentifier = valueIdentifier
        self.iconView.image = icon
        self.iconView.accessibilityIdentifier = iconIdentifier
        self.iconView.contentMode = .scaleAspectFit
    }
}

private extension SavingDetailElementView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        self.addSubview(stackView)
        stackView.fullFit(topMargin: 0, bottomMargin: 0, leftMargin: 16, rightMargin: 16)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: valueLabel.topAnchor, constant: 2),
            iconView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])

        self.titleLabel.textColor = .brownishGray
        self.titleLabel.scaledFont = .typography(fontName: .oneB300Regular)
        self.valueLabel.textColor = .lisboaGray
        self.valueLabel.scaledFont = .typography(fontName: .oneH100Bold)
        self.configureTap()
        self.setAccessibilityIdentifiers()
    }

    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilitySavingDetails.detailView.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilitySavingDetails.titleDetail.rawValue
        self.valueLabel.accessibilityIdentifier = AccessibilitySavingDetails.subtitleDetail.rawValue
    }

    func configureTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(tapGestureRecognizer:)))
        self.iconView.isUserInteractionEnabled = true
        self.iconView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(tapGestureRecognizer: UITapGestureRecognizer) {
        self.onTouchIconSubject.send()
    }
}
