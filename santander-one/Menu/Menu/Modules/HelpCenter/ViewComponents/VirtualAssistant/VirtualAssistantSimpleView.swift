//
//  VirtualAssistantSimpleView.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 26/02/2020.
//

import UI
import CoreFoundationLib

protocol VirtualAssistantSimpleViewProtocol: AnyObject {
    func didTapView(fromOtherConsultations: Bool)
}

class VirtualAssistantSimpleView: XibView {
    @IBOutlet private var viewSimple: UIView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    weak var delegate: VirtualAssistantSimpleViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tap)
        configureAccessibilityIdentifiers()
    }
    
    public func configureLabels(isFirstView: Bool) {
        if isFirstView {
            labelTitle.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
            labelTitle.textColor = UIColor.lisboaGray
            labelTitle.configureText(withKey: "helpCenter_label_wanted")
            bottomConstraint.constant = 0
        } else {
            labelTitle.configureText(withKey: "helpCenter_label_otherConsultations")
        }
    }
    
    private func configureAccessibilityIdentifiers() {
        labelTitle.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterLabelWanted.rawValue
        self.accessibilityIdentifier = AccesibilityHelpCenterPersonalArea.helpCenterListFaqs.rawValue
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.didTapView(fromOtherConsultations: true)
    }
}
