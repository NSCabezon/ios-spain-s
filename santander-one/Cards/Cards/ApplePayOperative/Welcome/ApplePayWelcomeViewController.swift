//
//  ApplePayWelcomeViewController.swift
//  Cards
//
//  Created by Jose Carlos Estela Anguita on 11/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

protocol ApplePayWelcomeViewProtocol: AnyObject {}

class ApplePayWelcomeViewController: UIViewController {
    
    private let presenter: ApplePayWelcomePresenterProtocol
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var applePayButton: PressableButton!
    @IBOutlet weak var applePayButtonView: UIView!
    @IBOutlet weak var applePayLogo: UIImageView!
    @IBOutlet weak var applePayButtonLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ApplePayWelcomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupNavigationBar()
    }
    
    // MARK: - Private
    
    func setupView() {
        self.imageView.image = Assets.image(named: "imgPay")
        self.titleLabel.configureText(withKey: "addCard_title_payMobile",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20),
                                                                                           lineHeightMultiple: 0.75))
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "addCard_text_applePay",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16),
                                                                                                 lineHeightMultiple: 0.75))
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.textColor = .lisboaGray
        self.applePayButtonLabel.text = localized("addCard_button_AddToApplePay")
        self.applePayButtonLabel.font = .santander(family: .text, size: 18)
        self.applePayButtonLabel.isUserInteractionEnabled = false
        self.applePayLogo.image = Assets.image(named: "icnApplePay")
        self.applePayLogo.isUserInteractionEnabled = false
        let addToApplePayGesture = UITapGestureRecognizer(target: self, action: #selector(addToApplePaySelected))
        self.applePayButton.addGestureRecognizer(addToApplePayGesture)
        self.applePayButton.pressedColor = .prominentSanGray
        self.setupGradient()
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_addApplePay")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: nil)
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor(red: 245.0/255.0, green: 249.0/255.0, blue: 252.0/255.0, alpha: 1.0).cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func addToApplePaySelected(_ sender: Any) {
        self.presenter.didSelectApplePay()
    }
}

extension ApplePayWelcomeViewController: ApplePayWelcomeViewProtocol {}
