//
//  StackedLabelView.swift
//  PersonalManager
//
//  Created by alvola on 03/02/2020.
//

import UIKit
import CoreFoundationLib

final class StackedLabelView: DesignableView {
    
    @IBOutlet weak var label: UILabel?
    private var fontSize: CGFloat = 20.0
    
    public func setText(_ string: LocalizedStylableText, fontSize: CGFloat) {
        label?.set(localizedStylableText: string)
        self.fontSize = fontSize
    }
    
    override func commonInit() {
        super.commonInit()
        configureLabel()
    }
    
    private func configureLabel() {
        label?.backgroundColor = UIColor.clear
        label?.font = UIFont.santander(size: fontSize)
        label?.textColor = UIColor.lisboaGray
        label?.lineBreakMode = .byWordWrapping
    }
}
