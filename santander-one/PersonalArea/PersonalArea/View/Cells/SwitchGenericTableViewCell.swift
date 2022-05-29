//
//  SwitchGenericTableViewCell.swift
//  Alamofire
//
//  Created by David Gálvez Alonso on 21/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

final class SwitchGenericTableViewCell: UITableViewCell, GeneralPersonalAreaCellProtocol, PersonalAreaActionCellProtocol {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cellSwitch: UISwitch!
    @IBOutlet private weak var separationView: DottedLineView!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var tooltipBackgroundView: UIView!
    
    private var infoText: String = ""
    
    weak var delegate: PersonalAreaActionCellDelegate?
    weak var customActiondelegate: PersonalAreaCustomActionCellDelegate?
    var action: PersonalAreaAction?
    var customAction: CustomAction?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetView()
    }
    
    func setCellInfo(_ info: Any?) {
        guard let info = info as? GenericCellModel else { return }
        self.titleLabel.configureText(withKey: info.titleKey)
        self.cellSwitch.isOn = info.valueInfo?.value as? Bool ?? false
        if let tooltipText = info.tooltipInfo?.message {
            setInfoText(tooltipText)
        }
        self.setAccessibilityIdentifiers(info)
    }
        
    func setCellDelegate(_ delegate: PersonalAreaActionCellDelegate?, action: PersonalAreaAction?) {
        self.delegate = delegate
        self.action = action
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        guard let action = self.action else {
            self.performCustomActionIfNeeded(mySwitch: mySwitch)
            return
        }
        Async.main { mySwitch.setOn(!mySwitch.isOn, animated: true) }
        self.delegate?.valueDidChange(action, value: mySwitch.isOn)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 55.0)
    }
}

extension SwitchGenericTableViewCell: PersonalAreaCustomActionCellProtocol {
    func setCustomActionCellDelegate(_ delegate: PersonalAreaCustomActionCellDelegate?, action: CustomAction?) {
        self.customActiondelegate = delegate
        self.customAction = action
    }
}

private extension SwitchGenericTableViewCell {
    func setInfoText(_ text: String) {
        self.infoText = text
        self.tooltipImageView.isHidden = false
        self.tooltipBackgroundView.isHidden = false
    }
    
    func commonInit() {
        self.resetView()
        self.configureView()
        self.configureLabels()
        self.configureTooltip()
        self.configureSwitch()
    }
    
    func configureView() {
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.separationView.backgroundColor = UIColor.clear
        self.separationView.strokeColor = UIColor.mediumSkyGray
    }
    
    func configureLabels() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = UIColor.lisboaGray
    }
    
    func configureSwitch() {
        self.cellSwitch.tintColor = .lightSanGray
        self.cellSwitch.backgroundColor = .lightSanGray
        self.cellSwitch.clipsToBounds = true
        self.cellSwitch.layer.cornerRadius = self.cellSwitch.frame.height / 2.0
        self.cellSwitch.transform = CGAffineTransform(scaleX: 0.778, y: 0.774)
        if let firstSub = self.cellSwitch.subviews.first, let thumb = firstSub.subviews.first(where: { $0 is UIImageView }) {
            thumb.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0.0, y: -0.8)
        }
        self.cellSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }
    
    func configureTooltip() {
        self.tooltipImageView.image = Assets.image(named: "icnSmallInfo")
        self.tooltipImageView.contentMode = .scaleAspectFill
        self.tooltipBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tooltipDidPressed)))
        self.tooltipBackgroundView.isUserInteractionEnabled = true
        self.tooltipImageView?.accessibilityIdentifier = AccessibilityConfigurationSectionPersonalArea.quickBalanceIcnInfo
    }
    
    @objc func tooltipDidPressed() {
        guard let associated = self.tooltipBackgroundView else { return }
        BubbleLabelView.startWith(associated: associated, text: self.infoText, position: .automatic)
    }

    func resetView() {
        self.titleLabel.text = ""
        self.tooltipImageView.isHidden = true
        self.tooltipBackgroundView.isHidden = true
    }
    
    func performCustomActionIfNeeded(mySwitch: UISwitch) {
        guard let action = self.customAction else { return }
        Async.main { mySwitch.setOn(!mySwitch.isOn, animated: true) }
        self.customActiondelegate?.valueDidChange(action, value: mySwitch.isOn)
    }
    
    func setAccessibilityIdentifiers(_ viewModel: GenericCellModel) {
        self.accessibilityIdentifier = viewModel.accessibilityIdentifier
        self.titleLabel.accessibilityIdentifier = viewModel.titleKey
        self.cellSwitch.accessibilityIdentifier = viewModel.valueInfo?.1
        self.tooltipImageView.accessibilityIdentifier = viewModel.tooltipInfo?.accessibilityIdentifier
    }
}
