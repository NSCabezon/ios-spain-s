//
//  SKCardSelectorDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import ESUI
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import SANSpainLibrary

final class SKCardSelectorViewController: UIViewController {
    
    @IBOutlet private weak var descriptionView: UIView!
    @IBOutlet private weak var cardsContainerView: OneGradientView!
    @IBOutlet private weak var continueButton: OneFloatingButton!
    @IBOutlet private weak var descriptionTitle: UILabel!
    @IBOutlet private weak var descriptionText: UILabel!
    @IBOutlet private weak var cardStackView: UIStackView!
    
    private let viewModel: SKCardSelectorViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKCardSelectorDependenciesResolver
    
    init(dependencies: SKCardSelectorDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKCardSelectorViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setAccessibilityIds()
        setAppearance()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        viewModel.didTapContinueButton()
    }
    
}

private extension SKCardSelectorViewController {
    func setAppearance() {
        cardsContainerView.setupType(.oneGrayGradient(direction: .topToBottom))
        setupLabels()
        setupButton()
    }
    
    func setupLabels() {
        self.descriptionTitle.configureText(withKey: "sanKey_title_selectCard", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24)))
        self.descriptionTitle.textColor = .lisboaGray
        self.descriptionText.configureText(withKey: "sanKey_text_selectCard", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14)))
        self.descriptionText.textColor = .lisboaGray
    }
    
    func setupButton() {
        let steps = viewModel.stepsCoordinator
        let current = (steps?.progress.current ?? -1) + 1
        continueButton.configureWith(
            type: OneFloatingButton.ButtonType.primary,
            size: OneFloatingButton.ButtonSize.large(OneFloatingButton.ButtonSize.LargeButtonConfig(
                        title: localized("generic_button_continue"),
                        subtitle: localized("sanKey_button_addPin", [StringPlaceholder(.number, "\(current)"), StringPlaceholder(.number, "\(steps?.progress.total ?? 0)")]).text,
                        icons: OneFloatingButton.ButtonSize.LargeButtonConfig.LargeIcons.right,
                        fullWidth: false)),
                    status: .ready)
        continueButton.isEnabled = false
    }
    
    func bind() {
        bindCards()
    }
    
    func setAccessibilityIds() {
        self.descriptionTitle.accessibilityIdentifier = AccessibilitySKCardSelector.labelTitle
        self.descriptionText.accessibilityIdentifier = AccessibilitySKCardSelector.labelSubtitle
    }
    
    func bindCards() {
        viewModel.state
            .case( CardSelectorState.cardsLoaded )
            .filter { !$0.isEmpty }
            .sink { [self] cards in
                cards.enumerated().forEach { (index, card) in
                    let cardView = OneProductCardView()
                    cardView.setupProductCard(card)
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(gesture:)))
                    cardView.tag = index
                    cardView.addGestureRecognizer(tapGestureRecognizer)
                    self.cardStackView.addArrangedSubview(cardView)
                }
            }.store(in: &subscriptions)
        
        viewModel.state
            .case( CardSelectorState.cardSelected )
            .sink { [self] (selected, row) in
                guard let subview = self.cardStackView.arrangedSubviews[row] as? OneProductCardView else { return }
                subview.setStatus(selected.cardStatus)
                continueButton.isEnabled = true
            }.store(in: &subscriptions)
    }
    
    @objc func handleTapGesture(gesture: UITapGestureRecognizer) {
        guard let row = gesture.view?.tag else { return }
        viewModel.didTappedCardAt(row: row)
    }
}

extension SKCardSelectorViewController: StepIdentifiable {}

public struct SKCardModel: OneProductCardViewRepresentable {
    public var title: String
    public var subTitle: String?
    public var defatultImageName: String?
    public var urlImage: String?
    public var logoSize: OneProductCardLogoHeight?
    public var moreActionsImageName: String?
    public var mainAmount: OneProductCardAmountRepresentable?
    public var extraAmounts: [OneProductCardAmountRepresentable]?
    public var infoExtra: LocalizedStylableText?
    public var firstNotification: OneNotificationRepresentable?
    public var secondNotification: OneNotificationRepresentable?
    public var thirdNotification: OneNotificationRepresentable?
    public var toggleNotification: OneNotificationRepresentable?
    public var cardStatus: OneProductCardStatus
    public var borderStyle: OneProductCardBorderStyle
    public var mainBackgroundColor: UIColor
    public var secundaryBackgroundColor: UIColor?
    public var pan : String?
    public var cardType: String?
    public var notificationTitleAccessibilityLabel: String?
    
    init(_ skRepresentable: SantanderKeyCardRepresentable){
        self.title = skRepresentable.description ?? ""
        self.urlImage = skRepresentable.img?.url ?? ""
        self.subTitle = (skRepresentable.cardType ?? "") + " | " + (skRepresentable.pan ?? "")
        self.pan = skRepresentable.pan ?? ""
        self.cardType = skRepresentable.cardType ?? ""
        self.defatultImageName = "oneDefaultCard"
        self.logoSize = .big
        self.cardStatus = .normal
        self.borderStyle = .line
        self.mainBackgroundColor = .oneWhite
        self.secundaryBackgroundColor = .oneSkyGray
    }

}

public protocol SKCardProtocol: SantanderKeyCardRepresentable, OneProductCardViewRepresentable {
    
}
extension SKCardProtocol {
    public var title: String {
        self.description ?? ""
    }
    
    public var urlImage: String? {
        self.img?.url
    }
    
    public var subTitle: String? {
        guard let cardType = cardType,
              let formattedPAN = pan
        else { return nil }
        
        return cardType + " | " + formattedPAN
    }
    
    public var defatultImageName: String? {
        "oneDefaultCard"
    }
    public var logoSize: OneProductCardLogoHeight? {
        .big
    }
    public var cardStatus: OneProductCardStatus {
        .normal
    }
    public var borderStyle: OneProductCardBorderStyle {
        .line
    }
    public var mainBackgroundColor: UIColor {
        .oneWhite
    }
    public var secundaryBackgroundColor: UIColor? {
        .oneSkyGray
    }
}

private struct MockOneProductCardAmount: OneProductCardAmountRepresentable {
    var title: String
    var amount: AmountRepresentable
}

public struct MockOneProductCardView: OneProductCardViewRepresentable {
    public var title: String = ""
    public var subTitle: String?
    public var defatultImageName: String?
    public var urlImage: String?
    public var logoSize: OneProductCardLogoHeight?
    public var moreActionsImageName: String?
    public var mainAmount: OneProductCardAmountRepresentable?
    public var extraAmounts: [OneProductCardAmountRepresentable]?
    public var infoExtra: LocalizedStylableText?
    public var firstNotification: OneNotificationRepresentable?
    public var secondNotification: OneNotificationRepresentable?
    public var thirdNotification: OneNotificationRepresentable?
    public var toggleNotification: OneNotificationRepresentable?
    public var cardStatus: OneProductCardStatus
    public var borderStyle: OneProductCardBorderStyle
    public var mainBackgroundColor: UIColor
    public var secundaryBackgroundColor: UIColor?
    public var notificationTitleAccessibilityLabel: String?
}
