//
//  OtherConsultView.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import UIKit
import CoreFoundationLib

final class OtherConsultView: XibView {
    @IBOutlet weak private var titleLabel: UILabel!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
   
    func setup() {
        self.titleLabel.text = localized("helpCenter_label_otherConsultations")
        self.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16.0)
        self.titleLabel?.textColor = UIColor.darkTorquoise
        self.accessibilityIdentifier = "areaOthersQueries"
        self.titleLabel.accessibilityIdentifier = "labelAreaOthersQueries"
    }
    
    func configureTitle(_ title: String) {
        self.titleLabel.text = localized(title)
    }
}
