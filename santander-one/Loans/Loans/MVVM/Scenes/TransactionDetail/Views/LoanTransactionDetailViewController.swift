import UIKit
import UI
import OpenCombine
import CoreDomain
import CoreFoundationLib

final class LoanTransactionDetailViewController: UIViewController {
    
    private let dependencies: LoanTransactionDetailDependenciesResolver
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    private var subscriptions: Set<AnyCancellable> = []
    private let viewModel: LoanTransactionDetailViewModel
    private var transactionCollectionView = LoanTransactionCollectionView(frame: .zero,
                                                                          collectionViewLayout: UICollectionViewFlowLayout())
    private var actionButtons = LoanTransactionDetailActionsView()
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var referenceView: UIView!
    @IBOutlet private weak var safeAreaBackground: UIView!
    private var detailConfiguration: LoanTransactionDetailConfigurationRepresentable?
    private let focusedTransactionSubject: PassthroughSubject<LoanTransactionDetailActionType, Never>
    private let hideLoadingSubject = PassthroughSubject<Void, Never>()
    
    init(dependencies: LoanTransactionDetailDependenciesResolver) {
        self.dependencies = dependencies
        self.navigationBarItemBuilder = dependencies.external.resolve()
        self.viewModel = dependencies.resolve()
        self.focusedTransactionSubject = actionButtons.didSelectActionSubject
        super.init(nibName: "LoanTransactionDetailViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.transactionCollectionView.layoutSubviews()
    }
}

private extension LoanTransactionDetailViewController {
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_movesDetail"))
            .setLeftAction(.back, associatedAction: .selector(#selector(didSelectGoBack)))
            .addRightAction(.menu, associatedAction: .selector(#selector(didSelectOpenMenu)))
            .build(on: self)
    }
    
    func setupViews() {
        self.view.backgroundColor = UIColor.skyGray
        self.referenceView.backgroundColor = UIColor.skyGray
        self.safeAreaBackground.backgroundColor = UIColor.skyGray
        self.stackView.addArrangedSubview(transactionCollectionView)
        self.stackView.addArrangedSubview(actionButtons)
    }
    
    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }
    
    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }
    
    func bind() {
        bindTransactionList()
        bindSelectedTransaction()
        bindSelectedTransactionDetail()
        bindTransactionDetailActions()
        bindTransactionScrollSelection()
        bindActionSelection()
        bindShowLoading()
        bindLoadedPDFData()
        bindShowError()
    }
    
    func bindTransactionList() {
        viewModel.state
            .case(LoanTransactionDetailState.transactionsLoaded)
            .compactMap { $0 }
            .map(mapToLoanTransactionDetailList)
            .sink { [unowned self] list in
                self.transactionCollectionView.setTransactionDetailList(list)
            }
            .store(in: &subscriptions)
    }
    
    func bindSelectedTransaction() {
        viewModel.state
            .case(LoanTransactionDetailState.transactionsSelected)
            .compactMap { $0 }
            .map(mapToLoanTransactionDetail)
            .sink { [unowned self] selected in
                self.transactionCollectionView.setSelectedViewModel(selected)
            }
            .store(in: &subscriptions)
    }
    
    func bindSelectedTransactionDetail() {
        viewModel.state
            .case(LoanTransactionDetailState.transationDetailLoaded)
            .compactMap { $0 }
            .map(mapToLoanTransactionDetail)
            .sink { [unowned self] transactionWithDetail in
                self.transactionCollectionView.updateTransactionDetail(transactionWithDetail)
            }
            .store(in: &subscriptions)
    }
    
    func bindTransactionDetailActions() {
        viewModel.state
            .case(LoanTransactionDetailState.actionsLoaded)
            .map(mapTransactionDetailActions)
            .sink { [unowned self] actions in
                self.actionButtons.removeSubviews()
                self.actionButtons.setActions(actions)
            }
            .store(in: &subscriptions)
    }
    
    func bindActionSelection() {
        Publishers.Zip(focusedTransactionPublisher(),
                       actionButtons.didSelectActionSubject)
            .sink { (focusedTransaction, action) in
                guard let transaction = focusedTransaction else { return }
                self.viewModel.didSelectAction(action,
                                               transactionDetail: transaction)
            }
            .store(in: &subscriptions)
    }
    
    func bindTransactionScrollSelection() {
        transactionCollectionView
            .didSelectTransactionSubject
            .sink { [unowned self] transaction in
                self.viewModel.didSelectTransaction(transaction)
            }
            .store(in: &subscriptions)
    }
    
    func bindShowLoading() {
        viewModel.state
            .case(LoanTransactionDetailState.isLoading)
            .sink { [unowned self] loading in
                loading ? self.showLoading() : self.dismissLoading(completion: { self.hideLoadingSubject.send() })
            }
            .store(in: &subscriptions)
    }
    
    func bindLoadedPDFData() {
        viewModel.state
            .case(LoanTransactionDetailState.pdfDataLoaded)
            .zip(hideLoadingSubject.eraseToAnyPublisher())
            .sink { (pdfParams, _) in
                let (pdfData, transaction, loan) = pdfParams
                self.viewModel.showPDF(pdfData, transaction: transaction, loan: loan)
            }
            .store(in: &subscriptions)
    }
    
    func bindShowError() {
        viewModel.state
            .case(LoanTransactionDetailState.errorReceived)
            .sink { [unowned self] _ in
                self.dismissLoading {
                    self.showGenericErrorDialog(withDependenciesResolver: self.dependencies.external.resolve())
                }
            }
            .store(in: &subscriptions)
    }
    
    func mapToLoanTransactionDetailList(list: [LoanTransactionRepresentable],
                                        loan: LoanRepresentable,
                                        detailConfig: LoanTransactionDetailConfigurationRepresentable) -> [LoanTransactionDetail] {
        self.detailConfiguration = detailConfig
        return list.map { transaction in
            LoanTransactionDetail(transaction: transaction,
                                  loan: loan,
                                  transactionDetailConfiguration: detailConfig,
                                  accountNumberFormatter: self.dependencies.external.resolve())
        }
    }
    
    func mapToLoanTransactionDetail(transaction: LoanTransactionRepresentable,
                                    loan: LoanRepresentable) -> LoanTransactionDetail {
        return mapToLoanTransactionDetail(detail: nil, transaction: transaction, loan: loan)
    }
    
    func mapToLoanTransactionDetail(detail: LoanTransactionDetailRepresentable?,
                                    transaction: LoanTransactionRepresentable,
                                    loan: LoanRepresentable) -> LoanTransactionDetail {
        return LoanTransactionDetail(transaction: transaction,
                                     loan: loan,
                                     transactionDetail: detail,
                                     transactionDetailConfiguration: self.detailConfiguration,
                                     accountNumberFormatter: self.dependencies.external.resolve())
    }
    
    func mapTransactionDetailActions(actions: [LoanTransactionDetailActionRepresentable], loan: LoanRepresentable) -> [LoanTransactionDetailAction] {
        return actions.map { action in
            LoanTransactionDetailAction(representable: loan,
                                        type: action.type,
                                        viewType: action.type.getViewType(),
                                        isDisabled: action.isDisabled,
                                        isUserInteractionEnable: action.isUserInteractionEnable)
        }
    }
}

extension LoanTransactionDetailViewController: LoadingViewPresentationCapable { }
extension LoanTransactionDetailViewController: GenericErrorDialogPresentationCapable { }
extension LoanTransactionDetailViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

// MARK: Publishers
private extension LoanTransactionDetailViewController {
    func focusedTransactionPublisher() -> AnyPublisher<LoanTransactionDetail?, Never> {
        focusedTransactionSubject
            .flatMap { [unowned self] _ in
                self.transactionCollectionView.focusedTransactionPublisher()
            }
            .receive(on: Schedulers.main)
            .eraseToAnyPublisher()
    }
}
