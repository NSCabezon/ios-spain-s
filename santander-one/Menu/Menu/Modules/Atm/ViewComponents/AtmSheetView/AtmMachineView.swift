//
//  AtmMachineView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/28/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol AtmMachineViewDelegate: AnyObject {
    func didSelectAtmMachineAddress(_ viewModel: AtmViewModel)
}

final class AtmMachineView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var stateView: UIView!
    @IBOutlet private weak var atmView: UIView!
    @IBOutlet private weak var imageArrow: UIImageView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var atmMachineButton: UIButton!
    private weak var delegate: AtmMachineViewDelegate?
    private var viewModel: AtmViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawShadows()
    }
    
    func setViewModel(_ viewModel: AtmViewModel) {
        self.viewModel = viewModel
        self.addressLabel.text = viewModel.address.camelCasedString
        self.distanceLabel.configureText(withLocalizedString: viewModel.distance)
        self.setStateAppearance(isOperative: viewModel.isOperative)
        self.addSpaceOnBottomIfNeeded(viewModel.isAtmDetailAvailable)
    }
    
    func setDelegate(_ delegate: AtmMachineViewDelegate?) {
        self.delegate = delegate
    }
    
    @IBAction func didSelectAtmMachine(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didSelectAtmMachineAddress(viewModel)
    }
}

private extension AtmMachineView {
    func setup() {
        self.addAccessibilityIdentifiers()
        self.setTexts()
        self.setColors()
        self.setBorders()
        self.imageArrow.image = Assets.image(named: "icnArrowLightGrey")
    }
    
    func setTexts() {
        self.titleLabel.configureText(withKey: "atm_title_atm")
    }
    
    func setColors() {
        self.titleLabel.textColor = .lisboaGray
        self.addressLabel.textColor = .lisboaGray
        self.distanceLabel.textColor = .lisboaGray
    }
    
    func setBorders() {
        self.atmView.drawBorder(cornerRadius: 4, color: .lightSkyBlue, width: 1)
    }
    
    func drawShadows() {
        self.atmView.drawShadow(offset: (x: 1, y: 2), color: .shadesWhite)
    }
    
    func setStateAppearance(isOperative: Bool) {
        if isOperative {
            self.setAvailableAppearance()
        } else {
            self.setUnavailableAppearance()
        }
    }
    
    func setAvailableAppearance() {
        self.stateLabel.textColor = .limeGreen
        self.stateView.drawBorder(cornerRadius: 2, color: .limeGreen, width: 1)
        self.stateLabel.text = localized("generic_button_operative").uppercased()
        self.stateView.backgroundColor = .white
    }
    
    func setUnavailableAppearance() {
        self.stateLabel.textColor = .coolGray
        self.stateView.drawBorder(cornerRadius: 2, color: .coolGray, width: 1)
        self.stateLabel.text = localized("atm_label_notAvailable").uppercased()
        self.stateView.backgroundColor = .whitesmokes
    }
    
    func addSpaceOnBottomIfNeeded(_ needBottomSpace: Bool) {
        self.bottomConstraint.constant = needBottomSpace ? 20 : 0
    }
    
    func addAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.title
        self.addressLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.address
        self.distanceLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.distance
        self.stateLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.status
        self.imageArrow.accessibilityIdentifier = AccessibilityAtm.AtmDetail.imageArrow
        self.atmMachineButton.accessibilityIdentifier = AccessibilityAtm.AtmDetail.atmBtnAtm
    }
}
