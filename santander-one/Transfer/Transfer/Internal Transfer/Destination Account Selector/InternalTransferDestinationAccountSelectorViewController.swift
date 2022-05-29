import UIKit
import Operative
import UI
import CoreFoundationLib

protocol InternalTransferDestinationAccountSelectorViewProtocol: OperativeView {
    func showAccounts(accountVisibles: [InternalTransferAccountSelectionViewModel], accountNotVisibles: [InternalTransferAccountSelectionViewModel])
    func showSelectedAccount(_ account: SelectedAccountHeaderViewModel)
    func showFaqs(_ items: [FaqsItemViewModel])
}

class InternalTransferDestinationAccountSelectorViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let presenter: InternalTransferDestinationAccountSelectorPresenterProtocol
    var sections: [InternalTransferAccountSection] = []

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: InternalTransferDestinationAccountSelectorPresenterProtocol) {
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
        self.setupNavigationBar()
        self.tableView.backgroundColor = .white
        self.view.backgroundColor = .skyGray
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }

    func setupView() {
        self.tableView.register(AccountSelectionTableViewCell.self, bundle: AccountSelectionTableViewCell.bundle)
        self.tableView.register(LabelArrowTableViewCell.self, bundle: LabelArrowTableViewCell.bundle)
    }
}

private extension InternalTransferDestinationAccountSelectorViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_destinationAccounts",
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

extension InternalTransferDestinationAccountSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension InternalTransferDestinationAccountSelectorViewController: InternalTransferDestinationAccountSelectorViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    func showAccounts(accountVisibles: [InternalTransferAccountSelectionViewModel], accountNotVisibles: [InternalTransferAccountSelectionViewModel]) {
        let builder = InternalTransferAccountSectionsBuilder(
            accountVisibles: accountVisibles,
            accountNotVisibles: accountNotVisibles)
        self.sections = builder.generateSections()
        self.tableView.reloadData()
    }
    
    func showSelectedAccount(_ account: SelectedAccountHeaderViewModel) {
        let headerView = HeaderView(frame: .zero, selectedAccountHeader: account)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableHeaderView = headerView
        headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
        headerView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}
extension InternalTransferDestinationAccountSelectorViewController: NotVisibleAccountSectionProtocol {}

extension InternalTransferDestinationAccountSelectorViewController: UITableViewDataSource {
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
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountDestinationSelector.accountVisibleItem + "_\(indexPath.row)"
        case .showMore:
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountDestinationSelector.accountLabelSeeHiddenAccounts
        case .notVisibleAccounts:
            cell.accessibilityIdentifier = AccessibilityInternTransferAccountDestinationSelector.accountNotVisibleItem + "_\(indexPath.row)"
        }
        return cell
    }
}

extension InternalTransferDestinationAccountSelectorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .visibleAccounts(let accounts), .notVisibleAccounts(let accounts, isExpanded: _):
            self.presenter.didSelectAccount(accounts[indexPath.row])
        case .showMore:
            self.updateNotVisibleAccounts()
        }
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .visibleAccounts, .notVisibleAccounts:
            guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
            cell.setHighlighted()
        case .showMore:
            break
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
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
        imageView.image = Assets.image(named: "icnEuroReceive")
        imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .lisboaGray
        label.configureText(withKey: "destinationAccounts_label_receiveMoney",
                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(frame: CGRect, selectedAccountHeader: SelectedAccountHeaderViewModel) {
        super.init(frame: frame)
        self.setupView(selectedAccountHeader: selectedAccountHeader)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(selectedAccountHeader: SelectedAccountHeaderViewModel) {
        self.addSubview(self.stackView)
        self.stackView.fullFit(bottomMargin: 20)
        self.stackView.addArrangedSubview(self.imageView)
        self.stackView.addArrangedSubview(self.label)
        self.add(selectedAccountHeader)
        self.imageView.centerXAnchor.constraint(equalTo: self.stackView.centerXAnchor).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: -16).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor, constant: 16).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
    }
    
    private func add(_ selectedAccountHeader: SelectedAccountHeaderViewModel) {
        let selectedAccountHeaderView = SelectedAccountHeaderView(frame: .zero)
        selectedAccountHeaderView.translatesAutoresizingMaskIntoConstraints = false
        selectedAccountHeaderView.setup(with: selectedAccountHeader)
        self.stackView.insertArrangedSubview(selectedAccountHeaderView, at: 0)
        selectedAccountHeaderView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        selectedAccountHeaderView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.label.accessibilityLabel = AccessibilityInternalTransferOrigin.label.rawValue
    }
}
