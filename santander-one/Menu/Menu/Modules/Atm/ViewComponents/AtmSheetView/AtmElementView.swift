//
//  AtmElementView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/28/20.
//
import UI
import CoreFoundationLib
import Foundation

final class AtmElementView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var stateView: UIView!
    @IBOutlet private weak var contentView: UIView!
    private var viewModel: AtmElementViewModel?
    
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
        self.setAppearanceFor(state: viewModel?.isAvailable ?? true)
    }
    
    func setViewModel(_ viewModel: AtmElementViewModel) {
        self.viewModel = viewModel
        self.titleLabel.configureText(withKey: viewModel.localizedKey)
        self.titleLabel.accessibilityIdentifier = viewModel.localizedKey
    }
}

private extension AtmElementView {
    func setup() {
        self.setTexts()
        self.setColors()
        self.addAccessibilityIdentifiers()
    }
    
    func setTexts() {
        self.titleLabel.text = "50€"
        self.stateLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setColors() {
        self.titleLabel.textColor = .lisboaGray
        self.backgroundColor = .white
        self.view?.backgroundColor = .clear
    }
    
    func addAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityAtm.AtmDetail.element
        self.stateLabel.accessibilityIdentifier = AccessibilityAtm.AtmDetail.status
    }
    
    func setAppearanceFor(state: Bool) {
        if state {
            self.setAvailableAppearance()
        } else {
            self.setUnavailableAppearance()
        }
    }
    
    func setAvailableAppearance() {
        self.stateLabel.configureText(withKey: "atm_label_available")
        self.contentView?.backgroundColor = .white
        self.stateView.backgroundColor = .white
        self.stateLabel.textColor = .limeGreen
        self.stateView.drawBorder(cornerRadius: 2, color: .limeGreen, width: 1)
        self.contentView.drawBorder(cornerRadius: 3.6, color: .mediumSkyGray, width: 1)
    }
    
    func setUnavailableAppearance() {
        self.stateLabel.configureText(withKey: "atm_label_notAvailable")
        self.contentView?.backgroundColor = .whitesmokes
        self.stateView.backgroundColor = .whitesmokes
        self.stateLabel.textColor = .coolGray
        self.stateView.drawBorder(cornerRadius: 2, color: .coolGray, width: 1)
        self.contentView.drawBorder(cornerRadius: 3.6, color: .white, width: 1)
    }
}
