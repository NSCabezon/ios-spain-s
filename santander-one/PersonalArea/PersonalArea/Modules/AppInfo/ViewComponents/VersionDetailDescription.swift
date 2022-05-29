//
//  VersionDetailDescription.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib

final class VersionDetailDescription: UIView {

    lazy private var versionNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.textAlignment = .left
        label.font = UIFont.santander(type: .bold, size: 14.0)
        label.textColor = UIColor.lisboaGray
        return label
    }()

    lazy private var versionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.santander(type: .light, size: 15.0)
        label.textColor = UIColor.lisboaGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setNumber(_ number: String, description: NSAttributedString) {
        versionNumberLabel.text = number
        versionNumberLabel.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.lasUpdateNumber
        versionDescriptionLabel.attributedText = description
        versionDescriptionLabel.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.lasUpdateLabel
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureView()
        configureLabels()
    }
    
    private func configureView() {
        backgroundColor = UIColor.white
    }
    
    private func configureLabels() {
        versionNumberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        versionNumberLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0).isActive = true
        versionNumberLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true

        versionDescriptionLabel.topAnchor.constraint(equalTo: versionNumberLabel.bottomAnchor, constant: 3.0).isActive = true
        self.bottomAnchor.constraint(equalTo: versionDescriptionLabel.bottomAnchor, constant: 20.0).isActive = true
        versionDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        self.trailingAnchor.constraint(equalTo: versionDescriptionLabel.trailingAnchor, constant: 16.0).isActive = true
    }
}
