//
//  ApplePaySuccessView.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 09/12/2019.
//

import UIKit
import CoreFoundationLib

public final class ApplePaySuccessView: UIView {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var activeImage: UIImageView!
    @IBOutlet weak var applePayLogo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var acceptButton: WhiteLisboaButton!
    
    // MARK: - Public
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Private
    
    private var view: UIView?
    
    private func setupView() {
        self.xibSetup()
        setAppearance()
    }
    
    private func xibSetup() {
        self.view = loadViewFromNib()
        self.view?.frame = bounds
        self.view?.backgroundColor = UIColor.bg
        self.view?.translatesAutoresizingMaskIntoConstraints = true
        self.view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view ?? UIView())
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView ?? UIView()
    }
    
    private func setAppearance() {
        self.backgroundColor = UIColor.clear
        self.view?.backgroundColor = UIColor.lisboaGray.withAlphaComponent(0.58)
        self.containerView.layer.cornerRadius = 5
        self.activeImage.image = Assets.image(named: "icnCheck")
        self.titleLabel.text = localized("addCard_alert_activated")
        self.titleLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.descriptionLabel.configureText(withKey: "addCard_alert_text_applePay")
        self.descriptionLabel.font = .santander(family: .text, type: .light, size: 15)
        self.closeButton.tintColor = .santanderRed
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        self.acceptButton.layer.cornerRadius = 20
        self.acceptButton.addSelectorAction(target: self, #selector(closeButtonSelected(_:)))
        self.acceptButton.setTitle(localized("generic_button_understand"), for: .normal)
        self.applePayLogo.image = Assets.image(named: "icnApplePay")
    }
    
    @IBAction private func closeButtonSelected(_ sender: UIButton) {
        self.removeFromSuperview()
    }
}
