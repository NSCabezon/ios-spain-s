//
//  AlmostDoneViewController.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 16/10/2020.
//

import UI
import CoreFoundationLib

protocol AlmostDoneViewProtocol: CardBoardingStepView {
    func setTips(_ tipsViewModel: [OfferTipViewModel])
}

final class AlmostDoneViewController: UIViewController {
    static let nibName: String  = "AlmostDoneViewController"
    @IBOutlet weak private var topShadow: UIView!
    @IBOutlet weak private var headerLabel: UILabel!
    @IBOutlet weak private var explanationLabel: UILabel!
    @IBOutlet weak private var tipsView: TipsImageCarousell!
    var isFirstStep: Bool = false

    private var tips: [OfferTipViewModel]? {
        didSet {
            guard let optionalTip = tips else { return }
            self.tipsView.setTips(optionalTip)
        }
    }
    
    let presenter: AlmostDonePresenterProtocol
    let bottomButtons = CardBoardingTabBar(frame: .zero)
    init(nibName: String?, bundle: Bundle?, presenter: AlmostDonePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupLabels()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    @objc func didSelectNext() {
        self.presenter.didSelectNext()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.applyGradientBackground(colors: [.white, .skyGray, .white], locations: [0.0, 0.9, 0.2])
    }
}

extension AlmostDoneViewController: AlmostDoneViewProtocol {
    func setTips(_ tipsViewModel: [OfferTipViewModel]) {
        self.tips = tipsViewModel
    }
}

private extension AlmostDoneViewController {
    func setupUI() {
        self.setupBottomButtons()
        self.headerLabel.setHeadlineTextFont(type: .regular, size: 38, color: .black)
        self.explanationLabel.setSantanderTextFont(type: .regular, size: 20.0, color: .lisboaGray)
        self.tipsView.delegate = self
        self.tipsView.backgroundColor = .clear
    }
    
    func setupBottomButtons() {
        self.view.addSubview(bottomButtons)
        self.bottomButtons.backButton.isHidden = self.isFirstStep
        self.bottomButtons.fitOnBottomWithHeight(72, andBottomSpace: 0)
        self.bottomButtons.addBackAction(target: self, selector: #selector(didSelectBack))
        self.bottomButtons.addNextAction(target: self, selector: #selector(didSelectNext))
        self.bottomButtons.nextButton.set(localizedStylableText: localized("cardBoarding_button_end"), state: .normal)
     }

    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .none
        )
        builder.build(on: self, with: nil)
    }
    
    func setupLabels() {
         let headingTitleFont: UIFont = .santander(family: .headline, type: .regular, size: 38.0)
         let aliasExplanationFont: UIFont = .santander(family: .text, type: .regular, size: 20.0)
         let headingTitleConfiguration = LocalizedStylableTextConfiguration(font: headingTitleFont,
                                                                            alignment: .natural,
                                                                            lineHeightMultiple: 0.75,
                                                                            lineBreakMode: .byWordWrapping)
         let aliasExplanationConfiguration = LocalizedStylableTextConfiguration(font: aliasExplanationFont,
                                                                                alignment: .left,
                                                                                lineHeightMultiple: 0.80,
                                                                                lineBreakMode: .byWordWrapping)
         self.headerLabel.configureText(withKey: "cardBoarding_title_almostFinished",
                                              andConfiguration: headingTitleConfiguration)
         self.headerLabel.textColor = .black
         self.explanationLabel.configureText(withKey: "cardBoarding_text_otherOptions",
                                                  andConfiguration: aliasExplanationConfiguration)
         self.explanationLabel.textColor = .lisboaGray
        self.headerLabel.accessibilityIdentifier = AccessibilityCardBoarding.AlmostDone.header
        self.explanationLabel.accessibilityIdentifier = AccessibilityCardBoarding.AlmostDone.explanation
     }
}

extension AlmostDoneViewController: TipsImageCarrouselDelegate {
    func didSelectTip(_ tip: OfferTipViewModel) {
        self.presenter.didSelectTip(tip)
    }
}
