//
//  HelpCenterProductOneVIPView.swift
//  Menu
//
//  Created by alvola on 29/09/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class HelpCenterProductOneVIPView: UIView {
    
    private lazy var oneIconImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.accessibilityIdentifier = "icnOneFlame"
        addSubview(image)
        NSLayoutConstraint.activate([image.heightAnchor.constraint(equalToConstant: 44.0),
                                     image.widthAnchor.constraint(equalToConstant: 44.0),
                                     image.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 12.0),
                                     image.topAnchor.constraint(equalTo: self.topAnchor, constant: -12.0)])
        return image
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "helpCenterBtnPlanOne"
        addSubview(view)
        NSLayoutConstraint.activate([view.heightAnchor.constraint(equalTo: self.heightAnchor),
                                     view.widthAnchor.constraint(equalTo: self.widthAnchor),
                                     view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                                     view.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        return view
        
    }()

    private lazy var iconImageView: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnAttVip"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.accessibilityIdentifier = "icnAttVip"
        contentView.addSubview(image)
        NSLayoutConstraint.activate([image.heightAnchor.constraint(equalToConstant: 40.0),
                                     image.widthAnchor.constraint(equalToConstant: 40.0),
                                     image.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8.0),
                                     image.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 18.0)])
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textColor = UIColor.lisboaGray
        label.configureText(withKey: "helpCente_button_planOne",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 16.0),
                                                                                 lineBreakMode: .byWordWrapping))
        label.accessibilityIdentifier = "helpCente_button_planOne"
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16.0),
            self.contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 34.0),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 18.0)
        ])
        return label
    }()
    
    private lazy var exclusiveLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.bostonRed
        label.configureText(withKey: "helpCente_subtitle_exclusivePlanOne",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .light, size: 12.0)))
        label.accessibilityIdentifier = "helpCente_subtitle_exclusivePlanOne"
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 24.0),
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16.0),
            self.contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 34.0),
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0.0)
        ])
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.mediumSanGray
        label.numberOfLines = 0
        label.configureText(withKey: "helpCente_text_exclusivePlanOne",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 14),
                                                                                 lineBreakMode: .byWordWrapping))
        label.accessibilityIdentifier = "helpCente_text_exclusivePlanOne"
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16.0),
            self.contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 34.0),
            label.topAnchor.constraint(equalTo: self.exclusiveLabel.bottomAnchor, constant: 0.0),
            self.contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 14.0)
        ])
        return label
    }()
    
    public var tapAction: (() -> Void)?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapAction?()
    }
}

private extension HelpCenterProductOneVIPView {
    func configureView() {
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.drawRoundedBorderAndShadow(with: ShadowConfiguration(color: UIColor.atmsShadowGray,
                                                                         opacity: 0.3,
                                                                         radius: 2.0,
                                                                         withOffset: 1.0,
                                                                         heightOffset: 2.0),
                                               cornerRadius: 4.0,
                                               borderColor: UIColor.mediumSkyGray,
                                               borderWith: 1.0)
        clipsToBounds = false
        descriptionLabel.layoutIfNeeded()
        oneIconImageView.image = Assets.image(named: "icnOneFlame")
    }
}
