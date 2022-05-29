//
//  SendMoneyView.swift
//  Transfer
//
//  Created by Juan Carlos López Robles on 12/18/19.
//

import UI
import CoreFoundationLib

class TransferActionHeader: UIView {
    private var view: UIView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.xibSetup()
        self.setAppearance()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setAppearance() {
        self.containerView.backgroundColor = UIColor.skyGray
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 18)
        self.titleLabel.textColor = UIColor.lisboaGray
        self.titleLabel.configureText(withKey: "transfer_title_options",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        self.titleLabel.accessibilityIdentifier = AccessibilityTransferHome.sendMoneyHomeLabelTransferActionTitle
    }
}
