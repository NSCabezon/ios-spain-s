import UIKit
import UI
import CoreFoundationLib

protocol AccountSelectorViewProtocol: class {
    func showAccounts(accountVisibles: [OldSelectableAccountViewModel], accountNotVisibles: [OldSelectableAccountViewModel])
}

class AccountSelectorViewController: BaseViewController<AccountSelectorPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    private var accountVisibles: [OldSelectableAccountViewModel] = []
    private var accountNotVisibles: [OldSelectableAccountViewModel] = []
    private var isVisibleHiddenCells: Bool = false
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    override func prepareView() {
        super.prepareView()
        self.presenter.selectorView = self
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCells(["OldSelectableProductViewCell"])
        self.tableView.register(LabelArrowTableViewCell.self, bundle: LabelArrowTableViewCell.bundle)
        tableView.estimatedSectionHeaderHeight = 60.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
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
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func back() {
        presenter.didTapBack()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension AccountSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension AccountSelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isNotVisibles() ? (self.isVisibleHiddenCells ? 3 : 2) : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.accountVisibles.count
        case 1:
            return 1
        case 2:
            return self.accountNotVisibles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch indexPath.section {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "OldSelectableProductViewCell", for: indexPath) as? OldSelectableProductViewCell
            (cell as? OldSelectableProductViewCell)?.setup(viewModel: self.accountVisibles[indexPath.row])
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "LabelArrowTableViewCell", for: indexPath) as? LabelArrowTableViewCell
            (cell as? LabelArrowTableViewCell)?.setAccountCellInfo(LabelArrowViewItem(numberPlaceHolder: self.accountNotVisibles.count), backgroundColor: .clear)
        case 2:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "OldSelectableProductViewCell", for: indexPath) as? OldSelectableProductViewCell
            (cell as? OldSelectableProductViewCell)?.setup(viewModel: self.accountNotVisibles[indexPath.row])
        default:
            break
        }
        cell?.accessibilityIdentifier = AccesibilityBills.billOriginAccount.rawValue
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.presenter.selected(viewModel: self.accountVisibles[indexPath.row])
        case 1:
            self.updateCells()
        case 2:
            self.presenter.selected(viewModel: self.accountNotVisibles[indexPath.row])
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = AccountSelectorHeaderView()
            tableView.removeUnnecessaryHeaderTopPadding()
            return headerView.sectionHeader(stringLoader.getString("generic_label_originAccountSelection"), width: tableView.contentSize.width)
        } else {
            return UIView(frame: .zero)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50.0
        } else {
            return 0.0
        }
    }
}

extension AccountSelectorViewController: AccountSelectorViewProtocol {
    func showAccounts(accountVisibles: [OldSelectableAccountViewModel], accountNotVisibles: [OldSelectableAccountViewModel]) {
        self.accountVisibles = accountVisibles
        self.accountNotVisibles = accountNotVisibles
        self.tableView.reloadData()
    }
}

private extension AccountSelectorViewController {
    func isNotVisibles() -> Bool {
        return self.accountNotVisibles.count > 0
    }
    
    func updateCells() {
        self.isVisibleHiddenCells = !self.isVisibleHiddenCells
        if !self.isVisibleHiddenCells {
            self.tableView.deleteSections(IndexSet(integer: 2), with: .none)
        } else {
            self.tableView.insertSections(IndexSet(integer: 2), with: .none)
        }
    }
}
