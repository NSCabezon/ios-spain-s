//
//  SecurityAreaHeaderView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

class SecurityAreaHeaderView: UIView {
    // MARK: - IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: DottedLineView!
    
    // MARK: - Variables
    var view: UIView?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.xibSetup()
        self.configureView()
        self.setAccessibilityIdentifiers()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.clear
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    // MARK: - Setup View
    private func configureView() {
        self.titleLabel.text = localized("security_title_config").uppercased()
        self.titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 13.0)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.iconImageView.image = Assets.image(named: "icnSettingOperation")
        self.separatorView.backgroundColor = UIColor.clear
        self.separatorView.strokeColor = UIColor.mediumSkyGray
    }

    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = "security_title_config"
    }
}
