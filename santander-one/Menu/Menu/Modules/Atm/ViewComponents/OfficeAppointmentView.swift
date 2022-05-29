//
//  OfficeAppointmentView.swift
//  Menu-Menu
//
//  Created by Rubén Márquez Fernández on 9/6/21.
//

import Foundation
import UI
import CoreFoundationLib

protocol OfficeAppointmentViewDelegate: AnyObject {
    func didSelectedOfficeAppointment(_ viewModel: OfferEntityViewModel?)
}

final class OfficeAppointmentView: XibView {
    
    // MARK: - View properties
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var cardLimitButton: UIButton!
    
    // MARK: - Attributes

    public var viewModel: OfferEntityViewModel?
    weak var delegate: OfficeAppointmentViewDelegate?

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
 
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawShadows()
    }
    
    // MARK: - Actions

    @IBAction func didSelectedCardLimitManagement(_ sender: Any) {
        self.delegate?.didSelectedOfficeAppointment(self.viewModel)
    }
}

private extension OfficeAppointmentView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.image = Assets.image(named: "icnCalendar")
        self.titleLabel?.font = .santander(family: .text, type: .regular, size: 20)
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.titleLabel?.configureText(withKey: "helpCenter_button_officeDate")
        self.subtitleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        self.subtitleLabel?.textColor = .lisboaGray
        self.subtitleLabel?.configureText(withKey: "helpCenter_text_officeDate")
        self.containerView.drawBorder(cornerRadius: 5, color: UIColor.lightSkyBlue, width: 1)
        self.containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.containerView.layer.shadowOpacity = 0.59
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.iconImageView.accessibilityIdentifier = AccessibilityAtm.icnCalendar.rawValue
        self.cardLimitButton.accessibilityIdentifier = AccessibilityAtm.cellOfficeAppointment.rawValue
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.labelTitleOfficeAppointment.rawValue
        self.subtitleLabel.accessibilityIdentifier = AccessibilityAtm.labelSubtitleOfficeAppointment.rawValue
    }
    
    func drawShadows() {
        self.containerView.drawShadow(offset: (x: 1, y: 2), color: .shadesWhite)
    }
}
