import UIKit
import Operative
import CoreFoundationLib
import UI

protocol InternalTransferAccountSelectorViewProtocol: OperativeView {
    func showAccounts(accountVisibles: [InternalTransferAccountSelectionViewModel], accountNotVisibles: [InternalTransferAccountSelectionViewModel])
    func showFaqs(_ items: [FaqsItemViewModel])
}

class InternalTransferAccountSelectorViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let presenter: InternalTransferAccountSelectorPresenterProtocol
    var sections: [InternalTransferAccountSection] = []

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: InternalTransferAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    func setupView() {
        self.view.backgroundColor = .skyGray
        self.tableView.register(AccountSelectionTableViewCell.self, bundle: AccountSelectionTableViewCell.bundle)
        self.tableView.register(LabelArrowTableViewCell.self, bundle: LabelArrowTableViewCell.bundle)
        let headerView = HeaderView(frame: .zero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableHeaderView = headerView
        headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
        headerView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
    }
}

private extension InternalTransferAccountSelectorViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(
                titleKey: "toolbar_title_originAccount",
                header: .title(key: "toolbar_title_transfer", style: .default))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @IBAction func faqs() {
        self.presenter.faqs()
    }
    
    @IBAction func close() {
        self.presenter.close()
    }

    func updateNotVisibleAccounts() {
        self.sections = self.sections.map { section in
            guard case let .notVisibleAccounts(accounts, isExpanded: isExpanded) = section else { return section }
            return .notVisibleAccounts(accounts, isExpanded: !isExpanded)
        }
        guard let section = self.getNotVisibleAccountsSection() else { return }
        self.tableView.reloadSections(IndexSet([section]), with: .automatic)
    }
}

extension InternalTransferAccountSelectorViewController: NotVisibleAccountSectionProtocol {}

extension InternalTransferAccountSelectorViewController: InternalTransferAccountSelectorViewProtocol, FaqsViewControllerDelegate {
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }

    func showAccounts(accountVisibles: [InternalTransferAccountSelectionViewModel], accountNotVisibles: [InternalTransferAccountSelectionViewModel]) {
        let builder = InternalTransferAccountSectionsBuilder(
            accountVisibles: accountVisibles,
            accountNotVisibles: accountNotVisibles)
        sections = builder.generateSections()
        tableView.reloadData()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension InternalTransferAccountSelectorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  self.sections[indexPath.section].cell(in: tableView, for: indexPath)
        switch self.sections[indexPath.section] {
        case .visibleAccounts:
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountSelector.accountVisibleItem + "_\(indexPath.row)"
        case .showMore:
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountSelector.accountLabelSeeHiddenAccounts + "_\(indexPath.row)"
        case .notVisibleAccounts:
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountSelector.accountNotVisibleItem + "_\(indexPath.row)"
        }
        return cell
    }
}

extension InternalTransferAccountSelectorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .visibleAccounts(let accounts), .notVisibleAccounts(let accounts, isExpanded: _):
            presenter.didSelectAccount(accounts[indexPath.row])
        case .showMore:
            updateNotVisibleAccounts()
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .visibleAccounts, .notVisibleAccounts:
            guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
            cell.setHighlighted()
        case .showMore:
            break
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .visibleAccounts, .notVisibleAccounts:
            guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
            cell.setUnhighlighted()
        case .showMore:
            break
        }
    }
}

private final class HeaderView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.image(named: "icnEuroUp")
        imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .lisboaGray
        label.configureText(withKey: "originAccount_label_sentMoney",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = AccessibilityInternalTransferOrigin.label.rawValue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.fullFit(bottomMargin: 20)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16).isActive = true
        label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16).isActive = true
        heightAnchor.constraint(equalToConstant: 134.0).isActive = true
        label.accessibilityLabel = AccessibilityInternalTransferOrigin.label.rawValue
        stackView.accessibilityIdentifier = AccessibilityInternalTransferOrigin.header.rawValue
    }
}
