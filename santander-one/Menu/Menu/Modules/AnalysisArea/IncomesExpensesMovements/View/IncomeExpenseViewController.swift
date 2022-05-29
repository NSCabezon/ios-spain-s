import UI
import CoreFoundationLib

protocol IncomeExpenseViewProtocol: AnyObject {
    func updateViewModel(_ viewModel: IncomeExpenseViewModel)
    func toggleSegmentToOperation(_ operationType: AccountMovementsType)
}

class IncomeExpenseViewController: UIViewController {
    private let presenter: IncomeExpensePresenterProtocol
    private let loadingView = FullViewLoading()
    @IBOutlet private weak var balanceSegmentedControl: LisboaSegmentedControl!
    @IBOutlet weak private var tableView: UITableView!
    private lazy var emptyView: SingleEmptyView = {
        let searchEmptyView = SingleEmptyView()
        searchEmptyView.isHidden = true
        return searchEmptyView
    }()
    private var movementsResume: ResumeMovementsView?
    private var viewModel: IncomeExpenseViewModel?
    init(presenter: IncomeExpensePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "IncomeExpenseViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

extension IncomeExpenseViewController: IncomeExpenseViewProtocol {
    func toggleSegmentToOperation(_ operationType: AccountMovementsType) {
        switch operationType {
        case .incomes:
            balanceSegmentedControl.selectedSegmentIndex = 0
        case .expenses:
            balanceSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    func updateViewModel(_ viewModel: IncomeExpenseViewModel) {
        self.viewModel = viewModel
        self.hideLoading()

        updateTableHeader()
        self.tableView.reloadData()
    }
}

private extension IncomeExpenseViewController {
    func updateEmptyViewTexts() {
        guard let viewModel = self.viewModel else {
            return
        }
        let month: String = presenter.monthLiteral
        let placeHolder = StringPlaceholder(.value, month)
        var title: LocalizedStylableText = LocalizedStylableText.empty
        switch viewModel.balanceType {
        case .expenses :
            title = localized("analysis_emptyView_expenses", [placeHolder])
        case .incomes:
            title = localized("analysis_emptyView_deposit", [placeHolder])
        }
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .headline, type: .regular, size: 20),
            alignment: .center,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        emptyView.updateTitle(title, styleConfig: localizedConfig)
    }
    
    func commonInit() {
        configureSegment()
        configureTableHeader()
        configureTableView()
        configureEmptyView()
        showLoading()
    }
    
    func configureNavigationBar() {
        let month: String = presenter.monthLiteral
        let title = localized("toolbar_title_balanceOf", [StringPlaceholder(.value, month)]).text
        NavigationBarBuilder(style: .white,
                             title: .title(key: title))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.menu(action: #selector(menuSelected)))
            .build(on: self, with: self.presenter)
    }
    
    func configureTableHeader() {
        self.movementsResume = ResumeMovementsView(frame: CGRect(x: 0, y: 0, width: 0, height: 74))
        self.tableView.tableHeaderView = self.movementsResume
        emptyView.isHidden = true
        self.tableView.addSubview(emptyView)
    }
    
    func showLoading() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func hideLoading() {
        loadingView.removeFromSuperview()
    }
    
    func updateTableHeader() {
        guard let viewModel = self.viewModel else {
            return
        }
        if viewModel.numberOfMovements() == 0 {
            self.updateEmptyViewTexts()
        }
        
        self.movementsResume?.configView(localized("analysis_label_numberOf"), viewModel.getHeaderAttributes().title)
        self.movementsResume?.configExtraView(localized("analysis_label_totalAmount"), viewModel.getHeaderAttributes().subtitle)
        guard self.movementsResume != nil else {
            return
        }
        self.emptyView.isHidden = !(viewModel.numberOfMovements() == 0)
        self.tableView.isScrollEnabled = self.emptyView.isHidden
    }
    
    func configureTableView() {
        let nib = UINib(nibName: "AnalysisBalanceCell", bundle: .module)
        self.tableView.register(nib, forCellReuseIdentifier: AnalysisBalanceCell.cellIdentifier)
        self.tableView.registerHeader(header: MonthTransfersDateSectionView.self, bundle: .module)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.accessibilityIdentifier = AccessibilityAnalysisArea.movementTable.rawValue
    }
    
    func configureEmptyView() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            emptyView.topAnchor.constraint(equalTo: self.movementsResume!.bottomAnchor, constant: 18),
            emptyView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 211.0)
        ])
    }
    
    @objc func menuSelected() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didChangeSegment(sender: LisboaSegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.viewModel?.balanceType = .incomes
        } else if sender.selectedSegmentIndex == 1 {
            self.viewModel?.balanceType = .expenses
        }
        self.updateEmptyViewTexts()
        self.updateTableHeader()
        self.tableView.reloadData()
    }
    
    func configureSegment() {
        self.balanceSegmentedControl.setup(with: ["search_tab_deposit", "search_tab_expenses"],
                       accessibilityIdentifiers: [AccessibilityAnalysisArea.incomeSegment.rawValue,
                                                  AccessibilityAnalysisArea.expenseSegment.rawValue])
        self.balanceSegmentedControl.backgroundColor = .skyGray
        self.balanceSegmentedControl.addTarget(self, action: #selector(didChangeSegment(sender:)), for: .valueChanged)
    }
    
    func isLastCellForIndexPath(_ indexPath: IndexPath) -> Bool {
        guard let viewModel = self.viewModel else {
            return false
        }
        let lastIndexInSection = viewModel.rowsAtSection(indexPath.section) - 1
        return lastIndexInSection == indexPath.row
    }
}

extension IncomeExpenseViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.rowsAtSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionalCell = tableView.dequeueReusableCell(withIdentifier: AnalysisBalanceCell.cellIdentifier, for: indexPath) as? AnalysisBalanceCell
        guard let item = viewModel?.itemAtIndexPath(indexPath), let cell = optionalCell else {
            return UITableViewCell()
        }
        cell.configureWithBalance(item, hideBottomLine: !isLastCellForIndexPath(indexPath), hideDiscontinue: isLastCellForIndexPath(indexPath))
        cell.selectionStyle = .none
        return cell
    }
}

extension IncomeExpenseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AnalysisBalanceCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let dateItem = viewModel?.sectionItemAt(section) else {
            return nil
        }
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MonthTransfersDateSectionView")
            as? MonthTransfersDateSectionView else { return nil }
        headerView.accessibilityIdentifier = AccessibilityAnalysisArea.dateHeader.rawValue
        headerView.hideSeparator(true)
        headerView.configure(withDate: dateItem.formatedLocalizedHeader())
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 37.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = viewModel?.itemAtIndexPath(indexPath) {
            presenter.showBalanceDetailForEntity(item)
        }
    }
}
