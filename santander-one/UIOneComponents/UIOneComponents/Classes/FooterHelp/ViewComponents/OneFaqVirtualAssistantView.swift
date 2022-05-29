//
//  OneFaqVirtualAssistantView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 23/11/21.
//

import UIKit
import CoreFoundationLib
import UI

class OneFaqVirtualAssistantView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
}

private extension OneFaqVirtualAssistantView {
    func setup() {
        self.titleLabel.text = localized("helpCenter_label_otherConsultations")
        self.titleLabel?.font = .typography(fontName: .oneB300Bold)
        self.titleLabel?.textColor = .oneDarkTurquoise
        self.accessibilityIdentifier = AccesibilityOneFooterHelp.oneFooterOtherConsultation
    }
}
