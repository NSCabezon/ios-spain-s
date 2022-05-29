//
//  FintechConfirmationMethodView.swift
//  Ecommerce
//
//  Created by alvola on 16/04/2021.
//

import UIKit
import UI
import CoreFoundationLib

final class FintechConfirmationMethodView: UIView {
    
    var biometryIconAction: ( () -> Void )?
    
    private lazy var icon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(size: 16)
        label.textColor = .lisboaGray
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        return label
    }()
    
    private var iconHeight: CGFloat {
        return Screen.isIphone4or5 ? 42.0 : 62.0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setConfirmationMethod(_ type: EcommerceAuthType, status: EcommerceAuthStatus) {
        switch type {
        case .faceId, .fingerPrint:
            setupTapGesture()
        case .code:
            break
        }
        configureImage(type.imageName())
        configureTitle(type.labelKeyWithStatus(status),
                       color: type.labelColorWithStatus(status))
    }
    
    func setPaymentStatus(_ status: EcommercePaymentStatus) {
        configureImage(status.imageName())
        configureTitle(status.messageKey(),
                       color: .lisboaGray)
    }
}

private extension FintechConfirmationMethodView {
    func setup() {
        configureIconConstraints()
        configureTitleConstraints()
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(iconTapped))
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func iconTapped() {
        biometryIconAction?()
    }
    
    func configureIconConstraints() {
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            icon.topAnchor.constraint(equalTo: self.topAnchor, constant: 19.0),
            icon.widthAnchor.constraint(equalToConstant: iconHeight),
            icon.heightAnchor.constraint(equalToConstant: iconHeight)
        ])
    }
    
    func configureTitleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 5.0)
        ])
    }
    
    func configureImage(_ imageName: String) {
        icon.image = Assets.image(named: imageName)
    }
    
    func configureTitle(_ title: String, color: UIColor) {
        titleLabel.configureText(withKey: title)
        titleLabel.textColor = color
    }
}
