//
//  SKBiometricsStepOnboardingViewController.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import UI
import UIKit
import Foundation
import OpenCombine
import ESUI
import UIOneComponents
import CoreFoundationLib

final class SKBiometricsStepOnboardingViewController: UIViewController {
    @IBOutlet private weak var headerView: SKHeaderView!
    @IBOutlet private weak var continueButton: OneFloatingButton!
    @IBOutlet private weak var biometricsActivationView: SKBiometricsActivationView!
    
    private let viewModel: SKBiometricsStepOnboardingViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKBiometricsStepOnboardingDependenciesResolver
    private let biometricsManager: LocalAuthenticationPermissionsManagerProtocol

    init(dependencies: SKBiometricsStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.biometricsManager = dependencies.external.resolve()
        super.init(nibName: "SKBiometricsStepOnboardingViewController", bundle: .module)
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

    @IBAction func didTouchContinue(_ sender: OneFloatingButton) {
        viewModel.didTouchContinue()
    }
}

private extension SKBiometricsStepOnboardingViewController {
    func setAppearance() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        headerView.configView(.small)
        headerView.setTitleFontSize(14.0)
        headerView.hideMoreInfoButton(true)
        biometricsActivationView.configure(biometricsManager.biometryTypeAvailable, enabled: biometricsManager.isTouchIdEnabled)
        continueButton.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(
                    title: "generic_button_continue",
                    icons: .none,
                    fullWidth: true)
            ),
            status: .ready)
    }
    
    func bind() {
        bindToggle()
    }

    private func bindToggle() {
        biometricsActivationView
            .publisher
            .sink(receiveValue: { [unowned self] isOn in
                self.biometryToggleEnabled(isOn)
            })
            .store(in: &subscriptions)
    }

    private func biometryToggleEnabled(_ isOn: Bool) {
        if !viewModel.didChangeSwitch(isOn, type: biometricsManager.biometryTypeAvailable) {
            biometricsActivationView.configure(biometricsManager.biometryTypeAvailable, enabled: biometricsManager.isTouchIdEnabled)
        }
    }
}
