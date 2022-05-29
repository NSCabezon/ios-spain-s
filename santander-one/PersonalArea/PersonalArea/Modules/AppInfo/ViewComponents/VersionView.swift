//
//  VersionView.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib

final class VersionView: UIView {
    
    lazy private var nameLabel: UILabel = {
        let label = self.initializaLabel()
        label.textColor = UIColor.lisboaGray
        return label
    }()
    
    lazy private var numberLabel: UILabel = {
        let label = self.initializaLabel()
        label.textColor = UIColor.darkTorquoise
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func setName(_ name: String, version: String) {
        self.nameLabel.text = name
        self.numberLabel.text = version
    }
    
    func setAccesibilityIdentifiers(_ nameId: String, _ numberId: String) {
        self.nameLabel.accessibilityIdentifier = nameId
        self.numberLabel.accessibilityIdentifier = numberId
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        self.configureView()
        self.configureLabels()
    }
    
    private func configureView() {
        self.backgroundColor = UIColor.white
        self.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
    }
    
    private func configureLabels() {
        self.nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        self.numberLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.numberLabel.trailingAnchor, constant: 16.0).isActive = true
        self.numberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.nameLabel.trailingAnchor, constant: 8.0).isActive = true
    }
    
    private func initializaLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.font = UIFont.santander(size: 16.0)
        return label
    }
}
