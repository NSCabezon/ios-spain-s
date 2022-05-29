//
//  MoreMovementsView.swift
//  Account
//
//  Created by alvola on 23/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class MoreMovementsView: UIView {
    var showMovementsButton: WhiteLisboaButton!
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .mediumSkyGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configureLabel()
    }
    
    private func configureLabel() {
        showMovementsButton = WhiteLisboaButton(frame: CGRect(x: 0.0, y: 0.0, width: frame.width - 48.0, height: 40.0))
        guard let showMovementsButton = showMovementsButton else { return }
        addSubview(showMovementsButton)
        addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        separator.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        separator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        showMovementsButton.titleLabel?.textColor = UIColor.santanderRed
        showMovementsButton.titleLabel?.font = UIFont.santander(family: .text, size: 16.0)
        
        showMovementsButton.setTitle(localized("product_button_seeMore"), for: .normal)

        showMovementsButton.translatesAutoresizingMaskIntoConstraints = true
        showMovementsButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        showMovementsButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        showMovementsButton.backgroundColor = UIColor.clear
        showMovementsButton.accessibilityIdentifier = "accountHome_btn_moreMoves"
    }
}
