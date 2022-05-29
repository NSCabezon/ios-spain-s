//
//  BizumNGOSearchView.swift
//  Bizum

import UIKit
import UI
import CoreFoundationLib
import ESUI

public protocol BizumNGOSearchViewDelegate: class {
    func launchAllOrganizationsView()
}

final class BizumNGOSearchView: XibView {

    static let identifier = "BizumNGOSearchView"
    @IBOutlet private weak var searchHeaderTitleLabel: UILabel!
    @IBOutlet private weak var searchTextField: UIView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var transparentView: UIView! {
        didSet {
            self.transparentView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        }
    }
    @IBOutlet private weak var organizationsLabel: UILabel!
    @IBOutlet private weak var organizationsImageView: UIImageView!
    @IBOutlet private weak var buttonView: UIView!
    lazy var enterNGOCodeView: LisboaTextField = {
        let view = LisboaTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public weak var delegate: BizumNGOSearchViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configView()
    }

    // MARK: Actions
    func hideSeparator(_ isHidden: Bool) {
        self.separatorView.isHidden = isHidden
    }
    
    func enableView() {
        self.transparentView.isHidden = true
    }

    func disableView() {
        self.transparentView.isHidden = false
    }

}

private extension BizumNGOSearchView {
    func configView() {
        self.separatorView.isHidden = true
        addNGOCodeView()
        configureNGOCodeTextField()
        configureButtonView()
        setAccessibilityIdentifiers()
    }
    
    func addNGOCodeView() {
        self.searchTextField.addSubview(self.enterNGOCodeView)
        self.enterNGOCodeView.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        self.enterNGOCodeView.fullFit(topMargin: 16, bottomMargin: 0, leftMargin: 16, rightMargin: 16)
    }
    
    func configureNGOCodeTextField() {
        let titleTextConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 18))
        searchHeaderTitleLabel.configureText(withLocalizedString: localized("bizum_label_enterOng"),
                                             andConfiguration: titleTextConfiguration)
        let conceptFormat = UIFormattedCustomTextField()
        conceptFormat.setMaxLength(maxLength: 5)
        conceptFormat.setAllowOnlyCharacters(.bizumConcept)
        self.enterNGOCodeView.setEditingStyle(.writable(configuration: LisboaTextField.WritableTextField(type: .floatingTitle,
                                                                                                               formatter: conceptFormat,
                                                                                                               disabledActions: [],
                                                                                                               keyboardReturnAction: nil,
                                                                                                               textfieldCustomizationBlock: setupAmountTextField(_:))))
        var conceptTextFieldStyle = LisboaTextFieldStyle.default
        conceptTextFieldStyle.fieldTextColor = .lisboaGray
        self.enterNGOCodeView.setStyle(conceptTextFieldStyle)
        self.enterNGOCodeView.placeholder = localized("bizum_hint_writeCode")
        self.enterNGOCodeView.setClearAccessory(.clearDefault)
    }
    
    func configureButtonView() {
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressButton)))
        buttonView.backgroundColor = UIColor.clear
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14.0))
        organizationsLabel.configureText(withKey: "bizum_label_seeListOngs",
                                         andConfiguration: configuration)
        organizationsLabel.textColor = UIColor.darkTorquoise
        organizationsImageView.image = ESAssets.image(named: "icnDonations")
    }
 
    @objc func didPressButton() {
        self.launchAllOrganizationsView()
    }
    func setupAmountTextField(_ component: LisboaTextField.CustomizableComponents) {
        component.textField.keyboardType = .numberPad
    }
    
    func setAccessibilityIdentifiers() {
        self.searchHeaderTitleLabel.accessibilityIdentifier = AccessibilityBizumDonation.enterCodeNGOLabel
        self.organizationsLabel.accessibilityIdentifier = AccessibilityBizumDonation.seeListNGOLabel
        self.enterNGOCodeView.accessibilityIdentifier = AccessibilityBizumDonation.enterCodeView
        self.enterNGOCodeView.isAccessibilityElement = true
    }
}

extension BizumNGOSearchView: BizumNGOSearchViewDelegate {
    func launchAllOrganizationsView() {
        delegate?.launchAllOrganizationsView()
    }
}
