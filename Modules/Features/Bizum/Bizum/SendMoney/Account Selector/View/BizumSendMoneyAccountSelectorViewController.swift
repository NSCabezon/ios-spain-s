import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol BizumSendMoneyAccountSelectorViewProtocol: class {
    func showAccounts(_ accounts: [BizumSendMoneyAccountSelectionViewModel], notVisibleAccounts: [BizumSendMoneyAccountSelectionViewModel])
}

final class BizumSendMoneyAccountSelectorViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    let presenter: BizumSendMoneyAccountSelectorPresenterProtocol
    private var sections: [Section] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BizumSendMoneyAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupView()
    }
}

extension BizumSendMoneyAccountSelectorViewController: BizumSendMoneyAccountSelectorViewProtocol {
    
    func showAccounts(_ accounts: [BizumSendMoneyAccountSelectionViewModel], notVisibleAccounts: [BizumSendMoneyAccountSelectionViewModel]) {
        if notVisibleAccounts.count == 0 {
            self.sections = [
                .visibleAccounts(accounts)
            ]
        } else {
            self.sections = [
                .visibleAccounts(accounts),
                .showMore(viewModel: LabelArrowViewItem(numberPlaceHolder: notVisibleAccounts.count)),
                .notVisibleAccounts(notVisibleAccounts, isExpanded: false)
            ]
        }
        self.tableView.reloadData()
    }
}

private extension BizumSendMoneyAccountSelectorViewController {
    enum Section {
        case visibleAccounts([BizumSendMoneyAccountSelectionViewModel])
        case showMore(viewModel: LabelArrowViewItem)
        case notVisibleAccounts([BizumSendMoneyAccountSelectionViewModel], isExpanded: Bool)
        
        func cell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
            switch self {
            case .visibleAccounts(let accounts):
                let cell = tableView.dequeueReusableCell(StandardAccountSelectionTableViewCell.self, indexPath: indexPath)
                cell.setup(with: accounts[indexPath.row])
                cell.accessibilityIdentifier = AccessibilityBizumSendMoneyAccountSelector.accountItem + "\(indexPath.row)"
                return cell
            case .notVisibleAccounts(let accounts, _):
                let cell = tableView.dequeueReusableCell(StandardAccountSelectionTableViewCell.self, indexPath: indexPath)
                cell.setup(with: accounts[indexPath.row])
                cell.accessibilityIdentifier = AccessibilityBizumSendMoneyAccountSelector.originAccountLabelSeeHiddenAccounts
                return cell
            case .showMore(viewModel: let viewModel):
                let cell = tableView.dequeueReusableCell(LabelArrowTableViewCell.self, indexPath: indexPath)
                cell.setAccountCellInfo(viewModel)
                cell.accessibilityIdentifier = AccessibilityBizumSendMoneyAccountSelector.accountNotVisibleItem + "\(indexPath.row)"
                return cell
            }
        }
        
        func numberOfRows() -> Int {
            switch self {
            case .visibleAccounts(let accounts):
                return accounts.count
            case .showMore:
                return 1
            case .notVisibleAccounts(let accounts, let isExpanded):
                return isExpanded ? accounts.count : 0
            }
        }
    }
    
    final class HeaderView: UIView {
        
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 6
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        private lazy var label: UILabel = {
            let label = UILabel()
            label.setSantanderTextFont(size: 20, color: .lisboaGray)
            label.configureText(withKey: "originAccount_label_sentMoney")
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            label.accessibilityIdentifier = AccessibilityBizumSendMoneyAccountSelector.originAccountLabelSentMoney
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            self.addSubview(self.stackView)
            self.stackView.fullFit(topMargin: 16, bottomMargin: 16)
            self.stackView.addArrangedSubview(self.label)
            self.label.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: -16).isActive = true
            self.label.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor, constant: 16).isActive = true
        }
    }
}

private extension BizumSendMoneyAccountSelectorViewController {
    
    func setupView() {
        self.setupTableView()
        self.setupHeader()
        self.setupNavigationBar()
    }
    
    func setupHeader() {
        let headerView = HeaderView(frame: .zero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableHeaderView = headerView
        headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
        headerView.topAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
    }
    
    func setupTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(StandardAccountSelectionTableViewCell.self, bundle: .uiModule)
        self.tableView.register(LabelArrowTableViewCell.self, bundle: .uiModule)
    }
    
    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_originAccount",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    func updateNotVisibleAccounts() {
        self.sections = self.sections.map { section in
            guard case let .notVisibleAccounts(accounts, isExpanded: isExpanded) = section else { return section }
            return .notVisibleAccounts(accounts, isExpanded: !isExpanded)
        }
        guard let section = self.notVisibleAccountsSection() else { return }
        self.tableView.reloadSections(IndexSet([section]), with: .bottom)
    }
    
    func notVisibleAccountsSection() -> Int? {
        guard let section = self.sections.enumerated().first(where: { _, section in
            switch section {
            case .notVisibleAccounts:
                return true
            default:
                return false
            }
        }) else {
            return nil
        }
        return section.0
    }
    
    @objc func close() {
        self.presenter.didSelectDismiss()
    }
}

extension BizumSendMoneyAccountSelectorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .visibleAccounts(let accounts), .notVisibleAccounts(let accounts, isExpanded: _):
            self.presenter.didSelectViewModel(accounts[indexPath.row])
        case .showMore:
            self.updateNotVisibleAccounts()
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .visibleAccounts, .notVisibleAccounts:
            guard let cell = tableView.cellForRow(at: indexPath) as? StandardAccountSelectionTableViewCell else { return }
            cell.setHighlighted()
        case .showMore:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .visibleAccounts, .notVisibleAccounts:
            guard let cell = tableView.cellForRow(at: indexPath) as? StandardAccountSelectionTableViewCell else { return }
            cell.setUnhighlighted()
        case .showMore:
            break
        }
    }
}

extension BizumSendMoneyAccountSelectorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cell(in: tableView, for: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].numberOfRows()
    }
}
