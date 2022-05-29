//
//  OperabilitySelectorViewController.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import UIKit
import Operative
import UI
import CoreFoundationLib

protocol OperabilitySelectorViewProtocol: OperativeView {
    func setOperabilityIndicator(_ indicator: OperabilityInd)
    func setContinueButtonIsEnabled(_ isEnabled: Bool)
    func showUnderageDialog()
    func showCMCDialog()
}

final class OperabilitySelectorViewController: UIViewController {

    @IBOutlet private weak var tooltipLabel: UILabel!
    @IBOutlet private weak var operativeIndicatorImageView: UIImageView!
    @IBOutlet private weak var operativeLabel: UILabel!
    @IBOutlet private weak var operativeInfoLabel: UILabel!
    @IBOutlet private weak var consultiveIndicatorImageView: UIImageView!
    @IBOutlet private weak var consultiveLabel: UILabel!
    @IBOutlet private weak var consultiveInfoLabel: UILabel!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var operativeView: UIView!
    @IBOutlet private weak var consultiveView: UIView!
    
    let presenter: OperabilitySelectorPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: OperabilitySelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter.viewDidLoad()
        self.navigationController?.navigationBar.setNavigationBarColor(.skyGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

extension OperabilitySelectorViewController: OperabilitySelectorViewProtocol {
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    func setOperabilityIndicator(_ indicator: OperabilityInd) {
        let imageUnselected = Assets.image(named: "icnRadioButtonUnSelected")
        let imageSelected = Assets.image(named: "icnRadioButtonSelected")
        
        operativeIndicatorImageView.image = indicator == .operative ? imageSelected : imageUnselected
        consultiveIndicatorImageView.image = indicator == .consultive  ? imageSelected : imageUnselected
        self.updateAccessibilityIdentifiers(indicator)
    }
    
    func setContinueButtonIsEnabled(_ isEnabled: Bool) {
        continueButton.setIsEnabled(isEnabled)
        continueButton.backgroundColor  = (isEnabled) ? .white : .silverDark
        if isEnabled == false {
            continueButton.borderColor = .silverDark
        }
    }
    
    func showUnderageDialog() {
        self.showDialogWithText(title: "generic_alert_information", description: "operability_alert_younger", button: "generic_button_understand")
        self.animateChangeOperabilityIndicator()
    }
    
    func showCMCDialog() {
        self.showDialogWithText(title: "generic_alert_information", description: "operability_alert_formalizeContract", button: "generic_button_understand")
    }
    
    func showDialogWithText(title: String, description: String, button: String) {
        let items: [LisboaDialogItem] = [
            LisboaDialogItem.margin(26),
            LisboaDialogItem.styledText(LisboaDialogTextItem(text: localized(title), font: UIFont.santander(family: FontFamily.headline, type: FontType.regular, size: 22), color: UIColor.black, alignament: NSTextAlignment.center, margins: (left: 16, right: 16))),
            LisboaDialogItem.margin(8),
            LisboaDialogItem.styledText(LisboaDialogTextItem(text: localized(description), font: UIFont.santander(family: FontFamily.text, type: FontType.regular, size: 16), color: UIColor.lisboaGray, alignament: NSTextAlignment.center, margins: (left: 40, right: 40))),
            LisboaDialogItem.margin(40),
            LisboaDialogItem.verticalAction(VerticalLisboaDialogAction(title: localized(button), type: LisboaDialogActionType.red, margins: (left: 16, right: 16), action: {})),
            LisboaDialogItem.margin(26)
        ]
        let dialog = LisboaDialog(items: items, closeButtonAvailable: false)
        dialog.showIn(self)
    }
}

private extension OperabilitySelectorViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_operability")
        )
        builder.build(on: self, with: nil)
     }
    
    func commonInit() {
        self.configureView()
        self.configureLabels()
        self.configureSelectors()
        self.configureContinueButton()
    }
    
    func configureView() {
        self.view.backgroundColor = .skyGray
    }
    
    func configureLabels() {
        self.tooltipLabel.textColor = .lisboaGray
        self.tooltipLabel.configureText(withKey: "tooltip_text_personalAreaUser",
                                   andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16)))
        self.operativeLabel.textColor = .lisboaGray
        self.operativeLabel.configureText(withKey: "personalArea_label_operative",
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
        self.consultiveLabel.textColor = .lisboaGray
        self.consultiveLabel.configureText(withKey: "personalArea_label_advisory",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16)))
        self.operativeInfoLabel.textColor = .grafite
        self.operativeInfoLabel.configureText(withKey: "operability_text_operator",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 13)))
        self.consultiveInfoLabel.textColor = .grafite
        self.consultiveInfoLabel.configureText(withKey: "operability_text_advisory",
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 13)))
        self.setAccessibilityIdentifiers()
    }
    
    func configureSelectors() {
        self.operativeView.isUserInteractionEnabled = true
        self.operativeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.indicatorSelected(sender:))))
        self.consultiveView.isUserInteractionEnabled = true
        self.consultiveView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.indicatorSelected(sender:))))
    }
    
    func configureContinueButton() {
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(self.continueButtonSelected))
        self.continueButton.setTitleColor(.white, for: .disabled)
    }
    
    func animateChangeOperabilityIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setOperabilityIndicator(.consultive)
        }
    }

    func setAccessibilityIdentifiers() {
        self.consultiveLabel.accessibilityIdentifier = AccessibilityOperabilitySelector.personalAreaLabelAdvisory
        self.tooltipLabel.accessibilityIdentifier = AccessibilityOperabilitySelector.tooltipTextPersonalAreaUser
        self.operativeLabel.accessibilityIdentifier = AccessibilityOperabilitySelector.personalAreaLabelOperative
        self.operativeInfoLabel.accessibilityIdentifier = AccessibilityOperabilitySelector.operabilityTextOperator
        self.consultiveInfoLabel.accessibilityIdentifier = AccessibilityOperabilitySelector.operabilityTextAdvisory
        self.continueButton.accessibilityIdentifier = AccessibilityOperabilitySelector.operabilitySelectorBtnContinue
    }
    
    func updateAccessibilityIdentifiers(_ indicator: OperabilityInd? = nil) {
        switch indicator {
        case .operative:
            self.operativeIndicatorImageView.accessibilityIdentifier = AccessibilityOperabilitySelector.icnOperativeSelected
            self.consultiveIndicatorImageView.accessibilityIdentifier = AccessibilityOperabilitySelector.icnAdvisoryUnselected
        case .consultive:
            self.operativeIndicatorImageView.accessibilityIdentifier = AccessibilityOperabilitySelector.icnOperativeUnselected
            self.consultiveIndicatorImageView.accessibilityIdentifier = AccessibilityOperabilitySelector.icnAdvisorySelected
        default:
            return
        }
    }
    
    @objc func continueButtonSelected() {
        self.presenter.didSelectContinue()
    }
    
    @objc func indicatorSelected(sender: UITapGestureRecognizer) {
        let senderType: OperabilityInd = sender.view == self.operativeView ? .operative : .consultive
        self.setOperabilityIndicator(senderType)
        self.presenter.didSelectIndicator(senderType)
    }
}
