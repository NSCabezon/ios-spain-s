import UI
import CoreFoundationLib

protocol BillsAndTaxesConfirmationPresenterProtocol: Presenter {
    var continueTitle: LocalizedStylableText { get }
    func next()
    func didTapFaqs()
    func didTapClose()
    func didTapBack()
    func trackFaqEvent(_ question: String, url: URL?)
}

class BillsAndTaxesConfirmationViewController: BaseViewController<BillsAndTaxesConfirmationPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.continueTitle, state: .normal)
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemsListHeader", "ConfirmationItemViewCell", "CheckTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .titleWithHeader(
                titleKey: styledTitle?.text ?? "",
                header: .title(
                    key: localizedSubTitleKey ?? "",
                    style: .default
                )
            )
        )
        builder.setLeftAction(.back(action: #selector(back)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    // MARK: - Private methods
    
    @IBAction private func continueButtonTapped(_ sender: UIButton) {
        self.presenter.next()
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func back() {
        presenter.didTapBack()
    }
    
    // MARK: - Progress Bar
    
    override var progressBarBackgroundColor: UIColor? {
        return .white
    }
}

extension BillsAndTaxesConfirmationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension BillsAndTaxesConfirmationViewController: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
}
