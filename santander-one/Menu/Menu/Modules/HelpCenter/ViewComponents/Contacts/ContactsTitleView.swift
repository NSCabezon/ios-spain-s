//
//  ContactsTitleView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 04/03/2020.
//

import UI
import CoreFoundationLib

class ContactsTitleView: XibView {
    @IBOutlet private weak var labelTitle: UILabel!
    
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
    }
}
