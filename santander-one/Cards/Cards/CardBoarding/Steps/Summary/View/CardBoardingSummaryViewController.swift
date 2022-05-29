//
//  SummaryViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/14/20.
//

import UI
import CoreFoundationLib
import Foundation

protocol CardBoardingSummaryViewProtocol: CardBoardingStepView {
    func setCardName(_ name: String)
    func setCardViewModel(_ viewModel: PlasticCardViewModel)
}

final class CardBoardingSummaryViewController: UIViewController {
    private let presenter: CardBoardingSummaryPresenterProtocol
    @IBOutlet private weak var santanderIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var readyCardLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var nowThatLabel: UILabel!
    @IBOutlet private weak var myCardsLabel: UILabel!
    @IBOutlet private weak var globalPositionLabel: UILabel!
    @IBOutlet private weak var improveLabel: UILabel!
    @IBOutlet private weak var myCardsButton: UIButton!
    @IBOutlet private weak var globalPositionButton: UIButton!
    @IBOutlet private weak var improveButton: UIButton!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var homeImageView: UIImageView!
    @IBOutlet private weak var improveImageView: UIImageView!
    @IBOutlet private weak var plasticCardView: PlasticCardView!
    @IBOutlet private weak var optionsContainerView: UIView!
    @IBOutlet private weak var backgroundView: UIView!
    var isFirstStep: Bool = false

    init(nibName: String?, bundle: Bundle?, presenter: CardBoardingSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true 
        self.enablePopGestureRecognizer(false)
    }
    
    @IBAction func didSelectMyCards(_ sender: Any) {
        self.presenter.didSelectMyCards()
    }
    
    @IBAction func didSelectGlobalPosition(_ sender: Any) {
        self.presenter.didSelectGlobalPosition()
    }
    
    @IBAction func didSelectImprove(_ sender: Any) {
        self.presenter.didSelectImprove()
    }
}

extension CardBoardingSummaryViewController: CardBoardingSummaryViewProtocol {
    func setCardViewModel(_ viewModel: PlasticCardViewModel) {
        self.plasticCardView.setViewModel(viewModel)
    }
    
    func setCardName(_ name: String) {
        let cardName = localized("cardBoarding_text_readyCard", [StringPlaceholder(.value, name)])
        self.readyCardLabel.configureText(withLocalizedString: cardName,
                                          andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.8))
    }
}

private extension CardBoardingSummaryViewController {
    func setup() {
        self.plasticCardView.increaseFontScaleBy(1.5)
        self.setColors()
        self.setImages()
        self.setText()
        self.accessibilityIdentifiers()
    }
    
    func setColors() {
        self.optionsContainerView.backgroundColor = .blueAnthracita
        self.descriptionLabel.textColor = .lisboaGray
        self.backgroundView.backgroundColor = .blueAnthracita
    }
    
    func setImages() {
        self.santanderIconImageView.image = Assets.image(named: "icnSanRedInfo")
        self.cardImageView.image = Assets.image(named: "icnCardMini")
        self.homeImageView.image = Assets.image(named: "icnHome")
        self.improveImageView.image = Assets.image(named: "icnLike")
    }
    
    func setText() {
        self.titleLabel.configureText(withKey: "cardBoarding_text_brilliant")
        self.nowThatLabel.configureText(withKey: "summary_label_nowThat")
        self.myCardsLabel.configureText(withKey: "generic_button_myCards")
        self.globalPositionLabel.configureText(withKey: "generic_button_globalPosition")
        self.improveLabel.configureText(withKey: "generic_button_improve")
        self.descriptionLabel.configureText( withKey: "cardBoarding_text_help",
            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.9)
        )
    }
    
    func accessibilityIdentifiers() {
        self.santanderIconImageView.accessibilityIdentifier = AccessibilityCardBoarding.Summary.imgSantander
        self.titleLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.title
        self.readyCardLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.readyCard
        self.descriptionLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.help
        self.nowThatLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.nowThat
        self.myCardsLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.myCards
        self.globalPositionLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.globalPosition
        self.improveLabel.accessibilityIdentifier = AccessibilityCardBoarding.Summary.improve
        self.myCardsButton.accessibilityIdentifier = AccessibilityCardBoarding.Summary.myCardsButton
        self.globalPositionButton.accessibilityIdentifier = AccessibilityCardBoarding.Summary.globalPositionButton
        self.improveButton.accessibilityIdentifier = AccessibilityCardBoarding.Summary.improveButton
    }
}
