import UI
import CoreFoundationLib
import Operative

protocol OperativeSummaryLisboaViewControllerProtocol {
    func addLocations(models: [OperativeSummaryStandardLocationViewModel])
}

final class OperativeSummaryLisboaViewController: BaseViewController<OperativeSummaryLisboaPresenterProtocol> {
    
    @IBOutlet private weak var headerStackView: UIStackView!
    @IBOutlet private weak var viewScrollView: UIView!
    @IBOutlet private weak var shortcutsView: OperativeSummaryLisboaShortcutsView!
    private lazy var headerView: OperativeSummaryLisboaHeaderView = {
        OperativeSummaryLisboaHeaderView()
    }()
    private lazy var amountView: OperativeSummaryLisboaDetailHeaderView = {
        OperativeSummaryLisboaDetailHeaderView()
    }()
    private lazy var arrowView: OperativeSummaryLisboaArrowView = {
        let view = OperativeSummaryLisboaArrowView()
        view.delegate = self
        return view
    }()
    private lazy var actionButtonsView: OperativeSummaryLisboaActionButtons = {
        let view = OperativeSummaryLisboaActionButtons()
        view.delegate = self
        return view
    }()
    private lazy var locationButtonsView: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    private var extraViews = [TransferSummaryLisboaDetailView]()
    private var startedArrowModel: OperativeSummaryLisboaDetailViewModel?
    private var lastArrowModel: OperativeSummaryLisboaDetailViewModel?
    private let extraViewsPosition = 4
    override class var storyboardName: String {
        "LisboaSummary"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackButton(true, animated: false)
        setupNavigationBar()
    }
}

private extension OperativeSummaryLisboaViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "genericToolbar_title_summary")
        )
        builder.setRightActions(.close(action: #selector(didTapCloseButton)))
        builder.build(on: self, with: nil)
        self.navigationBarTitleLabel.accessibilityIdentifier = AccessibilityTransfers.genericToolbarTitleSummary
    }
    
    @objc func didTapCloseButton() {
        presenter.didTapCloseButton()
    }
    
    func setupView() {
        view.backgroundColor = .blueAnthracita
        headerStackView.backgroundColor = .sky30
        viewScrollView.backgroundColor = .sky30
    }
    
    func setupLocationButtons() {
        let containerView = locationButtonsView.embedIntoView(topMargin: 14, bottomMargin: 0, leftMargin: 16, rightMargin: 16)
        containerView.backgroundColor = .sky30
        headerStackView.addArrangedSubview(containerView)
    }
    
    func setupActionButtons() {
        headerStackView.addArrangedSubview(actionButtonsView)
    }
    
    func setupFooter() {
        let sendMoneyAction = OperativeSummaryLisboaShortcutViewModel(title: localized(key: "generic_button_anotherSendMoney").text,
                                                                      imageName: "icnEnviarDinero",
                                                                      accessibilityIdentifier: AccessibilityTransferSummary.areaBtnAnotherPayment.rawValue) {
            self.presenter.didTapSendMoney()
        }
        let homeAction = OperativeSummaryLisboaShortcutViewModel(title: localized(key: "generic_button_globalPosition").text,
                                                                 imageName: "icnHome",
                                                                 accessibilityIdentifier: AccessibilityTransferSummary.areaBtnGlobalPosition.rawValue) {
            self.presenter.didTapGoToHome()
        }
        let helpUsToImproveAction = OperativeSummaryLisboaShortcutViewModel(title: localized(key: "generic_button_improve").text,
                                                                            imageName: "icnHelpUsMenu",
                                                                            accessibilityIdentifier: AccessibilityTransferSummary.areaBtnImprove.rawValue) {
            self.presenter.didTapHelpUsToImprove()
        }
        let elements = [sendMoneyAction, homeAction, helpUsToImproveAction]
        let viewModel = OperativeSummaryLisboaShortcutsViewModel(title: localized(key: "summary_label_nowThat").text,
                                                                 elements: elements)
        shortcutsView.setViewModel(viewModel)
    }
}

extension OperativeSummaryLisboaViewController {
    func setupHeader(_ viewModel: OperativeSummaryLisboaHeaderViewModel) {
        headerView.setViewModel(viewModel)
        headerStackView.addArrangedSubview(headerView)
    }
    
    func setupDetailHeader(_ viewModel: OperativeSummaryLisboaDetailHeaderViewModel) {
        amountView.setViewModel(viewModel)
        headerStackView.addArrangedSubview(amountView)
    }
    
    func setupDetail(_ viewModels: [OperativeSummaryLisboaDetailViewModel]) {
        startedArrowModel = viewModels.last
        for (index, viewModel) in viewModels.enumerated() {
            if index == viewModels.count - 1 {
                arrowView.setViewModel(viewModel)
                headerStackView.addArrangedSubview(arrowView)
            } else {
                let view = TransferSummaryLisboaDetailView()
                view.setViewModel(viewModel)
                headerStackView.addArrangedSubview(view)
            }
        }
        setupLocationButtons()
        setupActionButtons()
        setupFooter()
    }
    
    func setupExtraViews() {
        let viewModels = presenter.extraViewModels()
        var position = extraViewsPosition
        for (index, viewModel) in viewModels.enumerated() {
            if index == viewModels.count - 1 {
                lastArrowModel = viewModel
                arrowView.setViewModel(viewModel)
            } else {
                let view = TransferSummaryLisboaDetailView()
                view.isHidden = true
                view.setViewModel(viewModel)
                extraViews.append(view)
                headerStackView.insertArrangedSubview(view, at: position)
                position += 1
            }
        }
    }
    
    func addExtraAction(_ title: String, icon: String, action: @escaping () -> Void) {
        actionButtonsView.addAdditionalButton(title, icon: icon, action: action)
    }
    
    func addErrorView() {
        let viewModel = OperativeSummaryLisboaHeaderViewModel(imageName: "icnCloseOval",
                                                              title: localized(key: "summary_title_unrealized").text,
                                                              subtitleKey: nil,
                                                              descriptionKey: "summary_subtitle_errorImmediateOnePay",
                                                              isOk: false) // TODO: Translate
        headerView.setViewModel(viewModel)
        headerStackView.addArrangedSubview(headerView)
        setupFooter()
    }
    
    func addPendingView() {
        let viewModel = OperativeSummaryLisboaHeaderViewModel(imageName: "icnPendingOval",
                                                              title: localized(key: "summary_title_pending").text,
                                                              subtitleKey: nil,
                                                              descriptionKey: "summary_title_processedOperation",
                                                              isOk: false)
        headerView.setViewModel(viewModel)
        headerStackView.addArrangedSubview(headerView)
        setupFooter()
    }
}

// MARK: - OperativeSummaryLisboaArrowViewDelegate
extension OperativeSummaryLisboaViewController: OperativeSummaryLisboaArrowViewDelegate {
    func arrowPressed(colapsed: Bool) {
        if extraViews.isEmpty {
            setupExtraViews()
        }
        if let startedArrowModel = startedArrowModel, colapsed {
            arrowView.setViewModel(startedArrowModel)
        } else if let lastArrowModel = lastArrowModel {
            arrowView.setViewModel(lastArrowModel)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.extraViews.forEach({ $0.isHidden.toggle() })
        }, completion: { _ in
            self.arrowView.addBorders()
        })
    }
}

// MARK: - OperativeSummaryLisboaActionButtonsDelegate
extension OperativeSummaryLisboaViewController: OperativeSummaryLisboaActionButtonsDelegate {
    func pdfButtonPressed() {
        presenter.didTapPdfButton()
    }
    
    func shareButtonPressed() {
        presenter.didTapShareButton()
    }
}

extension OperativeSummaryLisboaViewController: OperativeSummaryLisboaViewControllerProtocol {
    func addLocations(models: [OperativeSummaryStandardLocationViewModel]) {
        for model in models {
            let view = OperativeSummaryStandardLocationView(model)
            locationButtonsView.addArrangedSubview(view)
        }
    }
}

extension OperativeSummaryLisboaViewController: BackNotAvailableViewProtocol {}
