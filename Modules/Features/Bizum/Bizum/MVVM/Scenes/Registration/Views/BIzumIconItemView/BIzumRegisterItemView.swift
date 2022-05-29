//
//  BIzumRegisterItemView.swift
//  Bizum
//
//  Created by Johnatan Zavaleta Milla on 21/4/22.
//

import Foundation
import UI
import UIKit

final class BizumRegisterItemView: UIView {
    private let widthMargin: CGFloat = 10.0
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.0).isActive = true
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        imageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8.0
        stack.alignment = .center
        stack.axis = .horizontal
        stack.setContentHuggingPriority(.required, for: .vertical)
        stack.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return stack
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configView()
    }
    
    public func configView(textKey: String, image: UIImage?, accessibilityIds: RegisterAccessibiltyItemView) {
        configTitleLabel(text: textKey)
        configLeftImage(image: image)
        setAccessibilityIds(accessibilityIds: accessibilityIds)
    }
}

private extension BizumRegisterItemView {
    
    func configView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 0),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: 0)
        ])
        stackView.addArrangedSubview(leftImageView)
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    func configTitleLabel(text: String) {
        descriptionLabel.textColor = .lisboaGray
        let subtitleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14),
                                                                       lineBreakMode: .byWordWrapping)
        descriptionLabel.configureText(withKey: text,
                                       andConfiguration: subtitleConfiguration)
    }
    
    func configLeftImage(image: UIImage?) {
        guard let image = image else { return }
        leftImageView.image = image
    }
    
    func setAccessibilityIds(accessibilityIds: RegisterAccessibiltyItemView) {
        descriptionLabel.accessibilityIdentifier = accessibilityIds.labelId
        leftImageView.accessibilityIdentifier = accessibilityIds.imageId
    }
}
