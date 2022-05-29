//
//  DeleteOtherBankConnectionViewController.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents
import CoreDomain

final class DeleteOtherBankConnectionViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var redButton: OneFloatingButton!
    @IBOutlet private weak var whiteButton: OneFloatingButton!
    @IBOutlet private weak var loadingView: UIView!
    private var networkError = false
    private var isDeleted = false
    
    private let viewModel: DeleteOtherBankConnectionViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: DeleteOtherBankConnectionDependenciesResolver
    private var bankSelected: ProducListConfigurationOtherBanksRepresentable?
    
    init(dependencies: DeleteOtherBankConnectionDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "DeleteOtherBankConnectionViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setAppearance()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
        UIAccessibility.post(notification: .layoutChanged, argument: self.navigationItem.titleView)
    }
}

private extension DeleteOtherBankConnectionViewController {
    func setAppearance() {
        setAskDeleteOtherBankAppearence()
    }
    
    func bind() {
        bindDeleteOtherBank()
        bindIsDeleteStatus()
    }
    
    func bindIsDeleteStatus() {
        viewModel.state
            .case(DeleteOtherBankConnectionState.isDeleteStatus)
            .sink { [unowned self] status in
                switch status {
                case .loading:
                    showLoadingView()
                case .deleted:
                    dismissLoadingView()
                    networkError = false
                    isDeleted = true
                    setAccessibilityIdentifiers()
                    setDeletedOtherBankAppearence()
                    setImageView(.deleted)
                case .notDeleted:
                    dismissLoadingView()
                    networkError = true
                    isDeleted = false
                    setAccessibilityIdentifiers()
                    setNotDeletedOtherBankAppearence()
                    setImageView(.notDeleted)
                }
            }.store(in: &subscriptions)
    }
    
    func bindDeleteOtherBank() {
        viewModel.state
            .case(DeleteOtherBankConnectionState.bankSelectedToDelete)
            .sink { [unowned self] bankInfo in
                self.bankSelected = bankInfo
                setAppearance()
            }.store(in: &subscriptions)
    }
    
    func setupViews() {
        configureButtons()
    }
    func configureNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_setting")
            .setLeftAction(.back, customAction: {
                self.isDeleted ? self.closeWithDeletedBank() : self.close()
            })
            .setRightAction(.close, action: {
                self.isDeleted ? self.closeWithDeletedBank() : self.close()
            })
            .build(on: self)
    }
    
    func configureViews() {
        configureLabels()
        configureButtons()
        setAccessibilityIdentifiers()
    }
    
    func getLoadingInfo() -> LoadingInfo {
        let type = LoadingViewType.onView(view: loadingView,
                                          frame: nil,
                                          position: .betweenTopAndCenter,
                                          controller: self)
        let text = LoadingText(
            title: localized("analysis_loading_deleteConnection", [StringPlaceholder(.name, (bankSelected?.companyName ?? ""))]),
            subtitle: localized("analisys_loading_fewSeconds"))
        let info = LoadingInfo(type: type,
                               loadingText: text,
                               loadingImageType: .jumps,
                               style: .bold,
                               gradientViewStyle: .solid,
                               spacingType: .basic,
                               loaderAccessibilityIdentifier: "",
                               titleAccessibilityIdentifier: "",
                               subtitleAccessibilityIdentifier: "")
        return info
    }
    
    func configureLabels() {
        topLabel.font = UIFont.typography(fontName: .oneH300Bold)
        bottomLabel.font = UIFont.typography(fontName: .oneH100Regular)
    }
    
    func configureButtons() {
        redButton.configureWith(type: .primary,
                                size: .medium(
                                    OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("analysis_button_deleteConnection"),
                                        icons: .none,
                                        fullWidth: true)),
                                status: .ready)
        whiteButton.configureWith(type: .secondary,
                                  size: .medium(
                                    OneFloatingButton.ButtonSize.MediumButtonConfig(
                                      title: localized("generic_button_cancel"),
                                      icons: .none,
                                      fullWidth: true)),
                                  status: .ready)
        redButton.addTarget(self, action: #selector(didTapRedButton), for: .touchUpInside)
        whiteButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    func setAskDeleteOtherBankAppearence() {
        topLabel.text = localized("analysis_label_removeConnectionBank", [StringPlaceholder(.name, (bankSelected?.companyName ?? ""))]).text
        bottomLabel.text = localized("analysis_label_removeBankProducts")
        imageView.setImage(url: bankSelected?.bankImageUrl ?? "")
        imageView.contentMode = .scaleAspectFit
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setLoadingAppearence() {
        topLabel.text = localized("analysis_loading_deleteConnection", [StringPlaceholder(.name, (bankSelected?.companyName ?? ""))]).text
        bottomLabel.text = localized("analisys_loading_fewSeconds")
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
        redButton.isHidden = true
        whiteButton.isHidden = true
        UIAccessibility.post(notification: .layoutChanged, argument: topLabel)
    }
    
    func setDeletedOtherBankAppearence() {
        topLabel.text = localized("analysis_label_deleteConnection", [StringPlaceholder(.name, (bankSelected?.companyName ?? ""))]).text
        bottomLabel.text = localized("analysis_label_notProductBankApp")
        redButton.configureWith(type: .primary,
                                size: .medium(
                                    OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("generic_button_accept"),
                                        icons: .none,
                                        fullWidth: true)),
                                status: .ready)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
        redButton.isHidden = false
        whiteButton.isHidden = true
        UIAccessibility.post(notification: .layoutChanged, argument: topLabel)
    }
    
    func setNotDeletedOtherBankAppearence() {
        topLabel.text = localized("analysis_label_notDeleteConnection", [StringPlaceholder(.name, (bankSelected?.companyName ?? ""))]).text
        bottomLabel.text = localized("analysis_label_tryAgain")
        redButton.configureWith(type: .primary,
                                size: .medium(
                                    OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("analysis_button_tryAgain"),
                                        icons: .none,
                                     fullWidth: true)),
                                status: .ready)
        whiteButton.configureWith(type: .secondary,
                                size: .medium(
                                    OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("analysis_button_goSettings"),
                                        icons: .none,
                                        fullWidth: true)),
                                status: .ready)
        redButton.isHidden = false
        whiteButton.isHidden = false
        UIAccessibility.post(notification: .layoutChanged, argument: topLabel)
    }
    
    func setImageView(_ status: DeleteOtherBankConnectionStatus) {
        var nameImage = ""
        switch status {
        case .deleted:
            nameImage = "oneIcnDeleteBank"
        case .notDeleted:
            nameImage = "oneIcnWarning"
        default:
            nameImage = ""
        }
        imageView.image = Assets.image(named: nameImage)
        imageView.contentMode = .scaleAspectFit
    }
    
    func showLoadingView() {
        loadingView.isHidden = false
        showLoadingOnViewWithLoading(info: getLoadingInfo())
    }
    
    func dismissLoadingView() {
        loadingView.isHidden = true
        dismissLoading()
    }
    
    func setAccessibilityInfo() {
        bottomLabel.accessibilityLabel = "\(bottomLabel.text ?? ""). \(localized("voiceover_youHaveTwoOptions"))"
        redButton.accessibilityLabel = redButton.getTitle()
        whiteButton.accessibilityLabel = whiteButton.getTitle()
        UIAccessibility.post(notification: .layoutChanged, argument: topLabel)
    }
    
    func setAccessibilityIdentifiers() {
        if isDeleted {
            imageView.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnDeleteBank
            topLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelDeleteConnection
            bottomLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelNotProductBankApp
            redButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnGenericAccept)")
        } else if networkError {
            imageView.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnWarning
            topLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelNotDeleteConnection
            bottomLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelTryAgain
            redButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnAnalysisTryAgain)")
            whiteButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnAnalysisGoSettings)")
        } else {
            imageView.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLogoBank
            topLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelRemoveConnectionBank
            bottomLabel.accessibilityIdentifier = AnalysisAreaAccessibility.labelRemoveBankProducts
            redButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnAnalysisDeleteConnection)")
            whiteButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnGenericCancel)")
        }
    }
    
    @objc func didTapRedButton() {
        isDeleted ? closeWithDeletedBank() : viewModel.didTapDeleteOtherBankConnection((bankSelected?.companyId ?? ""))
    }
    
    @objc func close() {
        viewModel.back()
    }
    
    @objc func closeWithDeletedBank() {
        viewModel.backWithDeletedBank()
    }
}

extension DeleteOtherBankConnectionViewController: LoadingViewPresentationCapable {}
extension DeleteOtherBankConnectionViewController: AccessibilityCapable {}
