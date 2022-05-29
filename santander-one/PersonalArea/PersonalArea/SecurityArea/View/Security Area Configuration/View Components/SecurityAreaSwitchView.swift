//
//  SecurityAreaSwitchView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol SecurityAreaSwitchProtocol: AnyObject {
    func didChangedSwitchValue(_ action: SecurityActionType, _ isSwitchOn: Bool)
}

protocol SecurityAreaCustomActionSwitchProtocol: AnyObject {
    func didChangedSwitchValue(_ action: CustomAction, _ isSwitchOn: Bool)
}

final class SecurityAreaSwitchView: UIView {
    // MARK: - IBOutlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var switchView: UISwitch!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var tooltipButton: UIButton!
    
    // MARK: - Variables
    var view: UIView?
    weak var delegate: SecurityAreaSwitchProtocol?
    weak var customActionDelegate: SecurityAreaCustomActionSwitchProtocol?
    var viewModel: SecuritySwitchViewModel?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: SecuritySwitchViewModel) {
        self.viewModel = viewModel
        self.nameLabel.configureText(withKey: viewModel.nameKey)
        self.nameLabel.textColor = UIColor.lisboaGray
        self.setSwitchState(viewModel.switchState)
        let isTooltipVisible = viewModel.tooltipMessage != nil
        self.tooltipImageView.isHidden = !isTooltipVisible
        self.tooltipButton.isHidden = !isTooltipVisible
        self.setAccessibilityIdentifier(viewModel)
    }
    
    public func setSwitchState(_ switchState: Bool) {
        self.switchView.isOn = switchState
    }
}

extension SecurityAreaSwitchView {
    func setupView() {
        self.xibSetup()
        self.configureView()
    }
    
    func xibSetup() {
        self.view = self.loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(self.view ?? UIView())
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    // MARK: - Setup
    func configureView() {
        self.nameLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.separatorView.backgroundColor = UIColor.clear
        self.separatorView.strokeColor = UIColor.mediumSkyGray
        self.switchView.tintColor = .lightSanGray
        self.switchView.backgroundColor = .lightSanGray
        self.switchView.layer.cornerRadius = self.switchView.frame.height / 2.0
        self.switchView.addTarget(self, action: #selector(self.switchChanged), for: .valueChanged)
        self.tooltipImageView.image = Assets.image(named: "icnInfoSmall")
        self.tooltipImageView.isHidden = true
        self.tooltipButton.addTarget(self, action: #selector(self.tooltipButtonPressed), for: .touchUpInside)
        self.tooltipButton.isHidden = true
    }
    
    @objc func switchChanged() {
        guard let viewModel = self.viewModel else { return }
        Async.main { self.switchView.setOn(!self.switchView.isOn, animated: true) }
        if let action = viewModel.action {
            self.delegate?.didChangedSwitchValue(action, switchView.isOn)
        } else if let customAction = viewModel.customAction {
            self.customActionDelegate?.didChangedSwitchValue(customAction, switchView.isOn)
        }
    }
    
    @objc func tooltipButtonPressed() {
        guard let infoText = self.viewModel?.tooltipMessage else { return }
        BubbleLabelView.startWith(associated: self.tooltipImageView, text: infoText, position: .automatic)
    }
    
    func setAccessibilityIdentifier(_ viewModel: SecuritySwitchViewModel) {
        self.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.container]
        self.tooltipButton.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.tooltip]
        self.switchView.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.action]
        self.nameLabel.accessibilityIdentifier = viewModel.nameKey
    }
}
