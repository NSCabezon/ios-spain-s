//
//  SuccessAppleEnrollmentView.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/8/20.
//

import Foundation
import UI
import CoreFoundationLib

protocol SuccessAppleEnrollmentViewDelegate: AnyObject {
    func didSelectHowToPay(_ viewModel: ApplePayOfferViewModel)
}

final class SuccessAppleEnrollmentView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cardView: PlasticCardView!
    @IBOutlet private weak var perfectLabel: UILabel!
    @IBOutlet private weak var applePayImageView: UIImageView!
    @IBOutlet private weak var successLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var howToPayButton: UIButton!
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var scrollContentView: UIView!
    private weak var delegate: SuccessAppleEnrollmentViewDelegate?
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
    
    func setViewModel(_ viewModel: PlasticCardViewModel) {
        self.cardView.setViewModel(viewModel)
    }
    
    func setOfferViewModel(_ viewModel: ApplePayOfferViewModel?) {
        self.offerViewModel = viewModel
        self.howToPayButton.isHidden = viewModel?.confirmationOffer == nil 
    }
    
    func setDelegate(_ delegate: SuccessAppleEnrollmentViewDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func didSelectHowToPay(_ sender: Any) {
        guard let offerViewModel = offerViewModel else { return }
        self.delegate?.didSelectHowToPay(offerViewModel)
    }
}

extension SuccessAppleEnrollmentView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}

private extension SuccessAppleEnrollmentView {
    func setup() {
        self.configureText()
        self.addAccessibilityIdentifier()
        self.setShadow()
        self.applePayImageView.image = Assets.image(named: "icnApplePaySummary")
        self.checkImageView.image = Assets.image(named: "icnCkeckOk")
        self.howToPayButton.setTitleColor(.darkTorquoise, for: .normal)
    }
    
    func configureText() {
        let configuration = LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75)
        self.titleLabel.configureText(withKey: "cardBoarding_title_payWithMobile", andConfiguration: configuration)
        self.perfectLabel.configureText(withKey: "generic_label_perfect")
        self.successLabel.configureText(withKey: "cardBoarding_label_activeSuccess")
        self.descriptionLabel.configureText(withKey: "cardBoarding_label_appleWalletPay")
        self.howToPayButton.setTitle(localized("cardBoarding_label_howPayWithMobile"), for: .normal)
    }
    
    func setShadow() {
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
    }
    
    func addAccessibilityIdentifier() {
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.title
        self.cardView.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.imgCard
        self.perfectLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.perfectText
        self.successLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.activeSuccess
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.appleWalletPay
        self.howToPayButton.accessibilityIdentifier = AccessibilityCardBoarding.ApplePay.howPayWithMobile
        self.applePayImageView.accessibilityIdentifier =  AccessibilityCardBoarding.ApplePay.icnApple
    }
}
