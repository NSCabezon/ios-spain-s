//
//  SKSecondStepOnboardingViewController.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents
import ESUI

final class SKSecondStepOnboardingViewController: UIViewController {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var phoneImageView: UIImageView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var oneFloatingButton: OneFloatingButton!
    @IBOutlet private weak var lockRoundedView: UIView!
    @IBOutlet private weak var oneAppLinkButton: OneAppLink!
    @IBOutlet private weak var lockRoundedImageView: UIImageView!
    
    private let viewModel: SKSecondStepOnboardingViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKSecondStepOnboardingDependenciesResolver
    
    init(dependencies: SKSecondStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKSecondStepOnboardingViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setAccessibilityIds()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setPopGestureEnabled(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setPopGestureEnabled(true)
    }
    
    @IBAction func oneFloatingButtonPressed(_ sender: Any) {
        viewModel.didSelectOneFloatingButton()
    }
    
    @IBAction func oneAppLinkPressed(_ sender: Any) {
        viewModel.didSelectSantanderConfiguration()
    }
}

private extension SKSecondStepOnboardingViewController {
    func setAppearance() {
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24), alignment: NSTextAlignment(CTTextAlignment.center))
        titleLabel.configureText(withLocalizedString: localized("sanKey_title_santanderKeySuccess"), andConfiguration: configuration)
        let firstDescriptionItem: SKItemDescriptionView = SKItemDescriptionView()
        firstDescriptionItem.configView(
            image: ESAssets.image(named: "oneIcnCheckOval"),
            text: "sanKey_text_confirmationQuickerAndSure",
            iconSize: SKItemDescriptionView.IconSize.small, accesibilityModel: SkItemAccesibilityModel(label: AccessibilitySkSecondStepOnboarding.firstItemLabel, image: AccessibilitySkSecondStepOnboarding.firstItemIconImage))
        let secondDescriptionItem: SKItemDescriptionView = SKItemDescriptionView()
        secondDescriptionItem.configView(
            image: ESAssets.image(named: "oneIcnCheckOval"),
            text: "sanKey_text_notificationPurchase",
            iconSize: SKItemDescriptionView.IconSize.small, accesibilityModel: SkItemAccesibilityModel(label: AccessibilitySkSecondStepOnboarding.secondItemLabel, image: AccessibilitySkSecondStepOnboarding.secondItemIconImage))
        stackView.addArrangedSubview(firstDescriptionItem)
        stackView.addArrangedSubview(secondDescriptionItem)
        lockRoundedView.roundCorners(
            corners: .allCorners,
            radius: 64 / 2)
        oneFloatingButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(
                    title: localized("generic_button_globalPosition"),
                    icons: .none,
                    fullWidth: true)),
            status: .ready)
        phoneImageView.image = ESAssets.image(named: "imgSanKeyTutorial")
        lockRoundedImageView.image = ESAssets.image(named: "IcnSanKeyLock")
        oneAppLinkButton.configureButton(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: localized("sanKey_label_settingsSanKey"),
                icons: OneAppLink.ButtonContent.ButtonIcons.none))
    }
    
    func bind() {
        
    }
    
    func setAccessibilityIds() {
        self.phoneImageView.accessibilityIdentifier = AccessibilitySkSecondStepOnboarding.imageView
        self.titleLabel.accessibilityIdentifier = AccessibilitySkSecondStepOnboarding.titleLabel
        self.lockRoundedImageView.accessibilityIdentifier = AccessibilitySkSecondStepOnboarding.headerImageView
    }
}
