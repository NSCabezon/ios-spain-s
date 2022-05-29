//
//  EcommerceEmptyPurchases.swift
//  Pods
//
//  Template created by Alvaro Royo.
//

import UIKit
import UI
import CoreFoundationLib

public protocol EcommerceEmptyPurchasesViewProtocol {
    func showSecureDevice(_ viewModel: EcommerceSecureDeviceViewModel)
}

public final class EcommerceEmptyPurchasesView: XibView {
    @IBOutlet private weak var secureDeviceView: UIView! {
        didSet {
            self.secureDeviceView.isHidden = true
        }
    }
    @IBOutlet private weak var secureDeviceTitle: UILabel! {
        didSet {
            self.secureDeviceTitle.textColor = .lisboaGray
            self.secureDeviceTitle.font = .santander(size: 18)
            self.secureDeviceTitle.accessibilityIdentifier = AccessibilitySecureDeviceEcommerce.statusDescriptionLabel
        }
    }
    @IBOutlet private weak var secureDeviceActionLabel: UILabel! {
        didSet {
            self.secureDeviceActionLabel.textColor = .darkTorquoise
            self.secureDeviceActionLabel.font = .santander(family: .headline, type: .bold, size: 14)
        }
    }
    @IBOutlet private weak var arrowIcon: UIImageView! {
        didSet {
            self.arrowIcon.image = Assets.image(named: "icnArrowBtn")?.withRenderingMode(.alwaysTemplate)
            self.arrowIcon.tintColor = .darkTorquoise
        }
    }
    
    @IBOutlet private weak var secureDeviceActionPressable: PressableButton! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnSecureDeviceAction))
            self.secureDeviceActionPressable.addGestureRecognizer(tapGesture)
            self.secureDeviceActionPressable.backgroundColor = .clear
            self.secureDeviceActionPressable.setup(style: PressableButtonStyle(pressedColor: .lightSky))
            self.secureDeviceActionPressable.accessibilityIdentifier = AccessibilitySecureDeviceEcommerce.updateStatusDescriptionBtn
        }
    }
    
    @IBOutlet private weak var topPointLine: DashedLineView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var bottomPointLine: DashedLineView!
    @IBOutlet private weak var emptyImage: UIImageView!
    @IBOutlet private weak var areaTextAdvice: UIView!
    @IBOutlet private weak var viewLoadingText: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet private weak var buttonVideoImg: UIImageView!
    @IBOutlet private weak var buttonVideoContainer: UIView!
    @IBOutlet private weak var buttonVideoText: UILabel!
    @IBOutlet private weak var buttonVideoShadow: UIView!
    @IBOutlet private weak var videoButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet private weak var leaveImage: UIImageView!
    @IBOutlet private weak var noPendingPurchasesText: UILabel!
    weak var secureDeviceDelegate: EcommerceSecureDeviceDelegate?
    
    var buttonAction: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    @IBAction func videoButtonAction() {
        self.buttonAction?()
    }
    
    @objc
    func didTapOnSecureDeviceAction() {
        self.secureDeviceDelegate?.didTapRegisterSecureDevice()
    }
}

private extension EcommerceEmptyPurchasesView {
    func setupView() {
        self.backgroundColor = .skyGray
        self.view?.backgroundColor = .skyGray
        [topPointLine, bottomPointLine].forEach {
            $0?.strokeColor = .brownGray
            $0?.dashPattern = [9, 2]
        }
        setTitle()
        setAreaTextAdvice()
        setVideoButton()
        setFooter()
    }
    
    func setTitle() {
        let config = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 18),
            alignment: .center,
            lineHeightMultiple: 0.85
        )
        self.title.textColor = .lisboaGray
        self.title.configureText(withKey: "ecommerce_title_advise", andConfiguration: config)
        self.title.accessibilityIdentifier = AccessibilitySecureDeviceEcommerce.titleAdviceLabel
    }
    
    func setAreaTextAdvice() {
        self.emptyImage.image = Assets.image(named: "ecommerceIllustrationLoading")
        self.areaTextAdvice.layer.cornerRadius = 7
        self.areaTextAdvice.backgroundColor = .darkSkyBlue
        let config = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .regular, size: 18),
            alignment: .center,
            lineHeightMultiple: 0.85
        )
        self.viewLoadingText.configureText(withKey: "ecommerce_text_advise", andConfiguration: config)
        self.viewLoadingText.accessibilityIdentifier = AccessibilitySecureDeviceEcommerce.subtitleAdviceLabel
        self.viewLoadingText.textColor = .lisboaGray
    }
    
    func setVideoButton() {
        self.buttonVideoImg.image = Assets.image(named: "icnPlayGreen26")
        let config = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: .light, size: 15),
            alignment: .left,
            lineHeightMultiple: 0.85
        )
        self.buttonVideoText.configureText(withKey: "ecommerce_button_video", andConfiguration: config)
        self.buttonVideoText.textColor = .lisboaGray
        self.buttonVideoShadow.drawShadow(offset: (0,2), opacity: 0.5, color: .gray, radius: 4)
        self.buttonVideoShadow.layer.cornerRadius = 6
        self.buttonVideoContainer.layer.cornerRadius = 6
    }
    
    func setFooter() {
        self.leaveImage.image = Assets.image(named: "ecommerceImgLeaves")
        let config = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, type: .bold, size: 16),
            alignment: .center,
            lineHeightMultiple: 0.85
        )
        self.noPendingPurchasesText.configureText(withKey: "ecommerce_label_empty", andConfiguration: config)
    }
    
    func setAccesibilityIds() {
        self.title.accessibilityIdentifier = AccessibilityEcommerceEmptyView.title
        self.viewLoadingText.accessibilityIdentifier = AccessibilityEcommerceEmptyView.viewLoadingText
        self.buttonVideoText.accessibilityIdentifier = AccessibilityEcommerceEmptyView.buttonVideoText
        self.videoButton.accessibilityIdentifier = AccessibilityEcommerceEmptyView.videoButton
        self.noPendingPurchasesText.accessibilityIdentifier = AccessibilityEcommerceEmptyView.noPendingPurchasesText
    }

}

extension EcommerceEmptyPurchasesView: EcommerceEmptyPurchasesViewProtocol {
    public func showSecureDevice(_ viewModel: EcommerceSecureDeviceViewModel) {
        self.secureDeviceView.isHidden = false
        self.secureDeviceTitle.configureText(withKey: viewModel.secureDeviceTitle)
        self.secureDeviceActionLabel.configureText(withKey: viewModel.secureDeviceAction)
    }
}
