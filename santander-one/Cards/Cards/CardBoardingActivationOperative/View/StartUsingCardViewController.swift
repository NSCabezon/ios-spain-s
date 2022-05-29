//
//  StartUsingCardViewController.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 07/10/2020.
//

import Foundation
import UIKit
import UI
import Operative
import CoreFoundationLib

protocol StartUsingCardViewProtocol: OperativeView {
    func showCard(viewModel: PlasticCardViewModel)
}

final class StartUsingCardViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var topShadow: UIView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var plasticCardView: PlasticCardView!
    @IBOutlet private weak var activateLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    let presenter: StartUsingCardPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: StartUsingCardPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupView()
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false 
        self.setAccessibilityIdentifier()
        self.removeTopNavigationInsets()
        self.navigationController?.disablePopGesture()
    }
    
    func removeTopNavigationInsets() {
        guard #available(iOS 11.0, *) else {
            self.automaticallyAdjustsScrollViewInsets = false
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .darkTorquoise),
            title: .none
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.title(title: localized("generic_buttom_noThanks"), action: #selector(didSelectClose), font: .santander(family: .text, type: .regular, size: 15), accessibilityIdentifier: "generic_buttom_noThanks")
        )
        builder.build(on: self, with: nil)
    }
    
    private func setupView() {
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 34),
        alignment: .center,
        lineHeightMultiple: 0.80,
        lineBreakMode: .byWordWrapping)
        let subtitleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 24),
        alignment: .center,
        lineHeightMultiple: 0.80,
        lineBreakMode: .byWordWrapping)
        self.backgroundImageView.image = Assets.image(named: "bgCardBoarding")
        self.titleLabel.textColor = .black
        self.titleLabel.configureText(withKey: "cardBoarding_title_activateCard",
        andConfiguration: titleConfiguration)
        self.subtitleLabel.configureText(withKey: "cardBoarding_subtitle_activateCard",
        andConfiguration: subtitleConfiguration)
        self.subtitleLabel.textColor = .lisboaGray
        self.activateLabel.textColor = .lisboaGray
        self.activateLabel.configureText(withKey: "cardBoarding_text_activateCard", andConfiguration: subtitleConfiguration)
        self.continueButton.setTitle(localized("cardBoarding_button_activateCard"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        self.plasticCardView.increaseFontScaleBy(1.3)
        self.topShadow.backgroundColor = .white
        self.topShadow.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
        
    }

    @objc private func didSelectContinue() {
        self.presenter.didSelectContinue()
    }
    
    @objc private func didSelectClose() {
        self.presenter.didSelectClose()
    }
    
    private func setAccessibilityIdentifier() {
        self.continueButton.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.continueButtonStartUsingCard
        self.titleLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.titleLabelStartUsingCard
        self.subtitleLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.subtitleLabelStartUsingCard
        self.activateLabel.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.activateLabelStartUsingCard
    }
}

extension StartUsingCardViewController: StartUsingCardViewProtocol {
    func showCard(viewModel: PlasticCardViewModel) {
        self.plasticCardView.setViewModel(viewModel)
        self.plasticCardView.layer.opacity = 0.5
    }
    
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
}

extension StartUsingCardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topShadow.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
