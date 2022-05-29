//
//  ContactsStackView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 04/03/2020.
//

import UI
import CoreFoundationLib

public final class ContactsStackView: XibView {
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet public weak var viewSuperline: UIView!
    @IBOutlet public weak var flipView: ContactsFlipView!
    @IBOutlet public weak var flipCallView: UIView!
    @IBOutlet public weak var phoneNumbersStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        labelTitle.configureText(withKey: "helpCenter_title_contact")
        viewSuperline.drawShadow(offset: (x: 0, y: 3), opacity: 0.05, color: UIColor.black, radius: 0.0)
        viewSuperline.drawBorder(cornerRadius: 5.0, color: UIColor.clear, width: 1.0)
        viewSuperline.layer.masksToBounds = false
        stackView.clipsToBounds = false
        labelTitle.accessibilityIdentifier = "helpCenter_title_contact"
    }
}
