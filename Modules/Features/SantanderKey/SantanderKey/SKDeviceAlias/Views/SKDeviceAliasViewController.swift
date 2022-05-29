//
//  SKDeviceAliasViewController.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 15/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import UIOneComponents
import CoreFoundationLib

final class SKDeviceAliasViewController : UIViewController {
    private let viewModel: SKDeviceAliasViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKDeviceAliasDependenciesResolver
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var aliasInputTitle: UILabel!
    @IBOutlet private weak var oneInputRegularView: OneInputRegularView!
    @IBOutlet private weak var continueButton: OneFloatingButton!
    
    init(dependencies: SKDeviceAliasDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKDeviceAliasViewController", bundle: .module)
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
        setPopGestureEnabled(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        guard let alias = oneInputRegularView.getInputText() else { return }
        self.viewModel.didTapContinueButton(alias: alias)
    }
}

private extension SKDeviceAliasViewController {
    func setAppearance() {
        self.gradientView.setupType(.oneGrayGradient())
        setupLabels()
        setupTextField()
        setupButton()
    }
    
    func setupLabels() {
        let titleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24), alignment: NSTextAlignment(CTTextAlignment.left))
        titleLabel.configureText(withLocalizedString: localized("sanKey_title_chooseAlias"), andConfiguration: titleConfiguration)
        titleLabel.textColor = .lisboaGray
        let subtitleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14), alignment: NSTextAlignment(CTTextAlignment.left))
        subtitleLabel.configureText(withLocalizedString: localized("sanKey_text_recognizeDevice"), andConfiguration: subtitleConfiguration)
        subtitleLabel.textColor = .lisboaGray
        let titleGradientConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .micro, type: .regular, size: 14), alignment: NSTextAlignment(CTTextAlignment.left))
        aliasInputTitle.configureText(withLocalizedString: localized("sanKey_input_alias"), andConfiguration: titleGradientConfiguration)
        aliasInputTitle.textColor = .lisboaGray
    }
    
    func setupTextField() {
        let viewModel = OneInputRegularViewModel(status: .activated,
                                                 text: UIDevice.current.model,
                                 placeholder: "",
                                 searchAction: .none,
                                 resetText: true)
        oneInputRegularView.setupTextField(viewModel)
    }

    func setupButton() {
        let steps = viewModel.stepsCoordinator
        let current = (steps?.progress.current ?? -1) + 1
        continueButton.configureWith(
            type: .primary,
            size: .large(OneFloatingButton.ButtonSize.LargeButtonConfig(
                title: localized("generic_button_continue"),
                subtitle: localized("sanKey_button_selectCard", [StringPlaceholder(.number, "\(current)"), StringPlaceholder(.number, "\(steps?.progress.total ?? 0)")]).text,
                icons: OneFloatingButton.ButtonSize.LargeButtonConfig.LargeIcons.right,
                fullWidth: false)),
            status: .ready)
    }

    func setAccessibilityIds() {
        self.titleLabel.accessibilityIdentifier = AccessibilitySKDeviceAlias.labelTitle
        self.subtitleLabel.accessibilityIdentifier = AccessibilitySKDeviceAlias.labelSubtitle
        self.aliasInputTitle.accessibilityIdentifier = AccessibilitySKDeviceAlias.textfieldTitle
    }
    
    func bind() {
        bindViewComponents()
        bindState()
    }
        
    func bindState() {
        viewModel
            .state
            .case { SKDeviceAliasState.textfFieldEmpty }
            .sink { [unowned self] empty in
                continueButton.isEnabled = !empty
            }
            .store(in: &subscriptions)
    }
        
    func bindViewComponents() {
        oneInputRegularView
            .publisher
            .case { ReactiveOneInputRegularViewState.textDidChange }
            .sink { [unowned self] text in
                viewModel.setTextfieldEmpty(text.isEmpty)
            }
            .store(in: &subscriptions)
    }
}

extension SKDeviceAliasViewController: StepIdentifiable {}
