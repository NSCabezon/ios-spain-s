//
//  BizumRegistrationViewController.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 11/4/22.
//

import UI
import ESUI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents

final class BizumRegistrationViewController: UIViewController {
    @IBOutlet private weak var backgroundImageview: UIImageView!
    @IBOutlet private weak var registerButton: OneFloatingButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    private let viewModel: BizumRegistrationViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: BizumRegistrationDependenciesResolver
    
    init(dependencies: BizumRegistrationDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "BizumRegistrationViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

private extension BizumRegistrationViewController {
    func setAppearance() {
        setupOneNavigationBar()
        setupBackgroundImageView()
        setupFloatingButton()
        setupLabels()
        setupStackView()
        setAcccessibiltyIds()
    }
    
    func setupOneNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_bizum")
            .setLeftAction(.back)
            .setRightAction(.close, action: {
                self.viewModel.didTapCloseButton()
            })
            .build(on: self)
    }
    
    func setupBackgroundImageView() {
        backgroundImageview.image = ESAssets.image(named: "oneImgBgCoinBizum")
        backgroundImageview.contentMode = .scaleToFill
        view.sendSubviewToBack(backgroundImageview)
    }

    func setupFloatingButton() {
        registerButton.configureWith(type: .primary,
                                     size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_registerInBizum"),
                                                                                                   icons: .right,
                                                                                                   fullWidth: true)),
                                     status: .ready)
        registerButton.setRightImage(image: "icnBizumWhite")
    }
    
    func setupLabels() {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.numberOfLines = .zero
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 28),
                                                                    lineBreakMode: .byWordWrapping)
        self.titleLabel.configureText(withKey: "bizum_title_instantlyMoneyMobile",
                                      andConfiguration: titleConfiguration)
        self.subTitleLabel.textColor = .lisboaGray
        self.subTitleLabel.numberOfLines = .zero
        let subtitleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 18),
                                                                       lineBreakMode: .byWordWrapping)
        self.subTitleLabel.configureText(withKey: "bizum_label_payEcommerce",
                                         andConfiguration: subtitleConfiguration)
    }
    
    func setupStackView() {
        let item1: BizumRegisterItemView = BizumRegisterItemView()
        item1.configView(textKey: "bizum_label_dischargedNumberPhone",
                         image: ESAssets.image(named: "oneIcnMobile"),
                         accessibilityIds: RegisterAccessibiltyItemView(labelId: AccessibilityBizumRegistration.RegisterItemView.firstItemLabel,
                                                                        imageId: AccessibilityBizumRegistration.RegisterItemView.firstItemImage))
        stackView.addArrangedSubview(item1)
        let item2: BizumRegisterItemView = BizumRegisterItemView()
        item2.configView(textKey: "bizum_label_selectAccount",
                         image: ESAssets.image(named: "oneIcnMoneyBag"),
                         accessibilityIds: RegisterAccessibiltyItemView(labelId: AccessibilityBizumRegistration.RegisterItemView.secondItemLabel,
                                                                        imageId: AccessibilityBizumRegistration.RegisterItemView.secondItemImage))
        stackView.addArrangedSubview(item2)
        let item3: BizumRegisterItemView = BizumRegisterItemView()
        item3.configView(textKey: "bizum_label_chooseSecretNumber",
                         image: ESAssets.image(named: "oneIcnLockBizum"),
                         accessibilityIds: RegisterAccessibiltyItemView(labelId: AccessibilityBizumRegistration.RegisterItemView.thirdItemLabel,
                                                                        imageId: AccessibilityBizumRegistration.RegisterItemView.thirdItemImage))
        stackView.addArrangedSubview(item3)
    }
        
    func setAcccessibiltyIds() {
        titleLabel.accessibilityIdentifier = AccessibilityBizumRegistration.titleLabel
        subTitleLabel.accessibilityIdentifier = AccessibilityBizumRegistration.subtitleLabel
    }
    
    func floatingButtonDidPressed() {
        viewModel.startRegistration()
    }
}

private extension BizumRegistrationViewController {
    func bind() {
        bindRegisterButtonView()
    }

    func bindRegisterButtonView() {
        registerButton.onTouchSubject
        .sink { [unowned self] in
            floatingButtonDidPressed()
        }.store(in: &subscriptions)
    }
}
