//
//  VirtualAssistantFaqsView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 02/03/2020.
//

import UI
import CoreFoundationLib

class VirtualAssistantFaqsView: XibView {
    @IBOutlet weak var stackViewFaqs: UIStackView!
    @IBOutlet private weak var borderView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        view?.layer.cornerRadius = 4.0
        borderView.layer.cornerRadius = 4.0
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        stackViewFaqs.layer.cornerRadius = 4.0
        borderView.translatesAutoresizingMaskIntoConstraints = false
    }
}
