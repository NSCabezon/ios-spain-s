//
//  AppInfoHeader.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib

protocol AppInfoHeaderDelegate: AnyObject {
    func updateDidPress()
}

final class AppInfoHeader: DesignableView {
    @IBOutlet private weak var appNameLabel: UILabel!
    @IBOutlet private weak var appIconImage: UIImageView!
    @IBOutlet private weak var updateButton: LisboaButton!
    @IBOutlet private weak var separationView: UIView!
    
    weak var delegate: AppInfoHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    public func setAppName(_ name: String) {
        self.appNameLabel.text = name
    }
    
    public func showUpdate(_ show: Bool) {
        self.updateButton.isHidden = !show
    }
    
    private func commonInit() {
        self.configureView()
        self.configureImage()
        self.configureLabel()
        self.configureButton()
    }
    
    private func configureView() {
        self.contentView?.backgroundColor = UIColor.skyGray
        self.separationView.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureImage() {
        self.appIconImage.image = Assets.image(named: "appSan")
        self.appIconImage.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.icon
    }
    
    private func configureLabel() {
        self.appNameLabel.font = UIFont.santander(family: .headline, type: .bold, size: 16.0)
        self.appNameLabel.textColor = UIColor.lisboaGray
    }
    
    private func configureButton() {
        self.updateButton.configureAsWhiteButton()
        self.updateButton.backgroundNormalColor = UIColor.clear
        self.updateButton.setTitle(localized("appInformation_button_update"), for: .normal)
        self.updateButton.addSelectorAction(target: self, #selector(self.updateDidPress))
        self.updateButton.accessibilityIdentifier = AccesibilityConfigurationPersonalArea.updateButton
    }
    
    @objc private func updateDidPress() {
        self.delegate?.updateDidPress()
    }
}
