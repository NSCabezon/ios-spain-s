//
//  RequirementView.swift
//  PersonalManager
//
//  Created by alvola on 03/02/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class RequirementView: DesignableView {
    @IBOutlet weak var dotView: UIView?
    @IBOutlet weak var label: UILabel?
    
    override func commonInit() {
        super.commonInit()
        configureView()
    }
    
    public func setTitle(_ string: LocalizedStylableText) {
        label?.set(localizedStylableText: string)
    }
    
    private func configureView() {
        dotView?.backgroundColor = UIColor.darkTorquoise
        dotView?.layer.cornerRadius = (dotView?.bounds.height ?? 0.0) / 2.0
        dotView?.clipsToBounds = true
        label?.font = UIFont.santander(size: 16.0)
        label?.textColor = .sanGreyDark
    }
}
