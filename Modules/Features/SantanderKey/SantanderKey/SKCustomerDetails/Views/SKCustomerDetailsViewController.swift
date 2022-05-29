//
//  SKCustomerDetailsViewController.swift
//  SantanderKey
//
//  Created by David Gálvez Alonso on 11/4/22.
//

import UI
import UIOneComponents
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import Operative

final class SKCustomerDetailsViewController: UIViewController, GenericErrorDialogPresentationCapable {
    @IBOutlet private weak var detailsHeaderView: SKCustomerDetailsHeaderView!
    @IBOutlet private weak var detailsBodyView: SKCustomerDetailsBodyView!
    @IBOutlet private weak var oneFooterHelpView: OneFooterHelpView!
    
    private let viewModel: SKCustomerDetailsViewModel
    private var toast: OneToastView?
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKCustomerDetailsDependenciesResolver
    private var baseUrl: String?
    private let biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    private let errorView = OneOperativeAlertErrorView()
    
    init(dependencies: SKCustomerDetailsDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.baseUrl = dependencies.external.resolve().resolve(for: BaseURLProvider.self).baseURL
        self.biometricsManager = dependencies.external.resolve()
        super.init(nibName: "SKCustomerDetailsViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

private extension SKCustomerDetailsViewController {
    
    func setupView() {
        setupNavigationBar()
        toast = OneToastView()
    }
    
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_santanderkey")
            .setLeftAction(.back)
            .setRightAction(.search, action: didTapOnSearch)
            .setRightAction(.menu, action: didTapOnMenu)
            .build(on: self)
    }
    
    func didTapOnSearch() {
        viewModel.goToSearch()
    }
    
    func didTapOnMenu() {
        viewModel.goToMenu()
    }
    
    func bind() {
        bindHeaderView()
        bindDetailResult()
        bindBodyView()
        bindHelpFooter()
        bindToggle()
        bindError()
        bindBiometryResult()
    }
    
    func bindHeaderView() {
        detailsHeaderView.state
            .case(SKCustomerDetailsHeaderState.didTapMoreInfo)
            .sink { [unowned self] in
                Toast.show(localized("generic_alert_notAvailableOperation"))
            }.store(in: &subscriptions)
    }
    
    func bindHelpFooter() {
        viewModel.state
            .case(SKCustomerDetailsState.faqsLoaded)
            .sink { [unowned self] oneFooterData in
                guard !oneFooterData.faqs.isEmpty || !oneFooterData.tips.isEmpty || oneFooterData.virtualAssistant else {
                    oneFooterHelpView.isHidden = true
                    return
                }
                let viewModel = OneFooterHelpViewModel(
                    faqs: oneFooterData.faqs.map { FaqsViewModel($0) },
                    tips: oneFooterData.tips.map { OfferTipViewModel($0, baseUrl: baseUrl ?? "") },
                    showVirtualAssistant: oneFooterData.virtualAssistant
                )
                oneFooterHelpView.setFooterHelp(viewModel)
            }
            .store(in: &subscriptions)
    }
    
    func bindDetailResult() {
        viewModel.state
            .case(SKCustomerDetailsState.didReceiveDetailResult)
            .sink { [unowned self] customerDetailType in
                //TODO biometryNotEnrolled
                detailsBodyView.configure(biometryType: biometricsManager.biometryTypeAvailable, biometryEnabled: biometricsManager.isTouchIdEnabled, customerDetailType: customerDetailType)
            }
            .store(in: &subscriptions)
    }
    
    func bindError() {
        guard let toast = toast else { return }
        toast.publisher
            .case(ReactiveOneToastViewState.didPressOptionalLink)
            .sink { [unowned self] _ in
                viewModel.retry = true
                toast.dismiss()
            }
            .store(in: &subscriptions)
        toast.publisher
            .case(ReactiveOneToastViewState.didDismiss)
            .sink { [unowned self] _ in
                viewModel.viewDidLoad()
            }
            .store(in: &subscriptions)
        viewModel.state
            .case(SKCustomerDetailsState.didFailed)
            .sink { [unowned self] _ in
                detailsBodyView.configure(biometryType: biometricsManager.biometryTypeAvailable, biometryEnabled: biometricsManager.isTouchIdEnabled, customerDetailType: .error)
                toast.setViewModel(OneToastViewModel(leftIconKey: "icnAlert", titleKey: nil, subtitleKey: "sanKey_label_errorConnection", linkKey: "sanKey_label_tryAgain", type: .small, position: .bottom, duration: .infinite))
                toast.present()
            }
            .store(in: &subscriptions)
        viewModel.state
            .case(SKCustomerDetailsState.showError)
            .sink { [unowned self] errorViewModel in
                guard var errorViewModel = errorViewModel else {
                    self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve())
                    return
                }
                errorView.setData(errorViewModel)
                BottomSheet().show(in: self,
                                   type: .custom(height: nil, isPan: true, bottomVisible: true),
                                   component: errorViewModel.typeBottomSheet,
                                   view: errorView)
            }.store(in: &subscriptions)
    }
    
    func bindBiometryResult() {
        guard let toast = toast else { return }
        viewModel.state
            .case(SKCustomerDetailsState.didReciveBiometryResult)
            .sink { [unowned self] in
                guard let message = $0.message else {
                    //TODO Failed biometry error
                    detailsBodyView.configure(biometryType: biometricsManager.biometryTypeAvailable, biometryEnabled: biometricsManager.isTouchIdEnabled, customerDetailType: .error)
                    toast.setViewModel(OneToastViewModel(leftIconKey: "icnAlert", titleKey: nil, subtitleKey: "", linkKey: nil, type: .small, position: .bottom, duration: .infinite))
                    toast.present()
                    return
                }
                if !$0.success {
                    detailsBodyView.configure(biometryType: biometricsManager.biometryTypeAvailable, biometryEnabled: biometricsManager.isTouchIdEnabled, customerDetailType: .error)
                }
                toast.setViewModel(OneToastViewModel(leftIconKey: "icnAlert", titleKey: nil, subtitleKey: message, linkKey: nil, type: .small, position: .bottom, duration: .infinite))
                toast.present()
            }
            .store(in: &subscriptions)
    }

    func bindBodyView() {
        detailsBodyView.publisher
            .case(SKCustomerDetailsDeviceInfoViewState.didTapOnLink)
            .sink { [unowned self] _ in
                viewModel.linkDevice()
            }
            .store(in: &subscriptions)
    }
    
    func bindToggle() {
        detailsBodyView.publisher
            .case(SKCustomerDetailsDeviceInfoViewState.didTapOnToggle)
            .sink(receiveValue: { [unowned self] isOn in
                viewModel.didChangeSwitch(isOn, type: biometricsManager.biometryTypeAvailable)
            })
            .store(in: &subscriptions)
    }
}
