//
//  AddApplePayView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/7/20.
//

import Foundation
import CoreFoundationLib
import UI

protocol AddApplePayViewDelegate: AnyObject {
    func didSelectEnrollInApplePay()
    func didSelectApplePayImage(_ viewModel: ApplePayOfferViewModel)
}

final class AddApplePayView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var applePayImageView: UIImageView!
    @IBOutlet private weak var applePayButtonView: UIView!
    @IBOutlet private weak var applePayIconImageView: UIImageView!
    @IBOutlet private weak var applePayTitleLabel: UILabel!
    @IBOutlet private weak var scrollContentView: UIView!
    private weak var delegate: AddApplePayViewDelegate?
    private var offerViewModel: ApplePayOfferViewModel?
    @IBOutlet weak var topShadow: UIView!
    
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
        self.scrollContentView.backgroundColor = .clear
        self.view?.applyGradientBackground(colors: [.white, .skyGray])
    }
    
    func addToView(_ parentView: UIView) {
        parentView.addSubview(self)
        self.fullFit(bottomMargin: 72)
    }
    
    @IBAction func didSelectApplePay(_ sender: Any) {
        self.delegate?.didSelectEnrollInApplePay()
    }
    
    func setDelegate(_ delegate: AddApplePayViewDelegate) {
        self.delegate = delegate
    }
    
    func setOfferViewModel(_ viewModel: ApplePayOfferViewModel?) {
        self.offerViewModel = viewModel
        guard let url = offerViewModel?.imageUrl else {
            self.applePayImageView.isHidden = false
            return
        }
        self.applePayImageView.loadImage(
        urlString: url,
        placeholder: Assets.image(named: "imgPay")) { [weak self] in
            guard let self = self else { return }
            self.applePayImageView.isHidden = false
            self.applePayImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didSelectOffer))
            self.applePayImageView.addGestureRecognizer(tapGesture)
        }
    }
}

private extension AddApplePayView {
    func setup() {
        self.configureText()
        self.addAccessibilityIdentifier()
        self.configureImages()
        self.setShadow()
    }
    
    func configureText() {
        let textConfiguration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75)
        self.titleLabel.configureText(withKey: "cardBoarding_title_payWithMobile", andConfiguration: textConfiguration)
        self.descriptionLabel.configureText(withKey: "cardBoarding_text_applePayments", andConfiguration: textConfiguration)
        self.applePayTitleLabel.configureText(withKey: "addCard_button_AddToApplePay")
    }
    
    func configureImages() {
        self.applePayImageView.isHidden = true
        self.applePayImageView.contentMode = .scaleAspectFill
        self.applePayImageView.image = Assets.image(named: "imgPay")
        self.applePayIconImageView.image = Assets.image(named: "icnApplePay")
    }
    
    private func setShadow() {
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
        let shadow = ShadowConfiguration(color: .shadowColor, opacity: 1, radius: 7, withOffset: 0, heightOffset: 0)
        self.applePayButtonView.drawRoundedBorderAndShadow(with: shadow, cornerRadius: 26, borderColor: .white, borderWith: 1)
        self.applePayButtonView.layer.masksToBounds = false
    }
    
    @objc
    func didSelectOffer() {
        guard let offerViewModel = self.offerViewModel else { return }
        self.delegate?.didSelectApplePayImage(offerViewModel)
    }
    
    func addAccessibilityIdentifier() {
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.title
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.text
        self.applePayButtonView.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.ngBtnAppleWallet
        self.applePayTitleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.addToApplePayText
    }
}

private extension UIColor {
    static let shadowColor =  UIColor(red: 156/256, green: 156/256, blue: 156/256, alpha: 0.5)
}

extension AddApplePayView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
