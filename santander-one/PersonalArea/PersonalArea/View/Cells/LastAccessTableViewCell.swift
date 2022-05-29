//
//  LastAccessTableViewCell.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 13/08/2020.
//

import UI
import UIKit
import CoreFoundationLib

final class LastAccessTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol {
    @IBOutlet private weak var lastAccessLabel: UILabel!
    @IBOutlet private weak var lastAccessDateLabel: UILabel!
    @IBOutlet private weak var containerStackView: UILabel!
    @IBOutlet private weak var separationView: DottedLineView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let infoViewModel = info as? LastLogonViewModel else {
            self.setTextIfNeeded(info: info)
            return
        }
        self.lastAccessDateLabel.text = infoViewModel.lastLogonDate
    }
}

// MARK: - Private Methods
private extension LastAccessTableViewCell {
    func commonInit() {
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        self.contentView.heightAnchor.constraint(equalToConstant: 57).isActive = true
        self.configureLabels()
        self.setAccesibilityIdentifiers()
        self.setSeparationView()
    }
    
    func configureLabels() {
        self.lastAccessLabel.configureText(withKey: "personalArea_button_lastAccess")
        [self.lastAccessLabel, self.lastAccessDateLabel].forEach { $0.font = UIFont.santander(family: .text, type: .regular, size: 16) }
        self.lastAccessLabel.textColor = .lisboaGray
        self.lastAccessDateLabel.textColor = .darkTorquoise
    }
    
    func setAccesibilityIdentifiers() {
        self.lastAccessLabel.accessibilityIdentifier = AccessibilityLastAccessCell.personalAreaLabelLastAccess
        self.lastAccessDateLabel.accessibilityIdentifier = AccessibilityLastAccessCell.personalAreaLabelLastAccessDate
        self.accessibilityIdentifier = AccessibilityLastAccessCell.personalAreaBtnLastAccess
    }
    
    func setTextIfNeeded(info: Any?) {
        guard let infoTextKey = info as? String else { return }
        self.lastAccessDateLabel.configureText(withKey: infoTextKey)
    }
    
    func setSeparationView() {
        self.separationView?.backgroundColor = UIColor.clear
        self.separationView?.strokeColor = UIColor.mediumSkyGray
    }
}
