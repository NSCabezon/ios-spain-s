import UIKit
import CoreFoundationLib
import UI

struct BillAccountSelectionViewModel: AccountSelectionViewModelProtocol {
    let account: AccountEntity
    
    var currentBalanceAmount: NSAttributedString {
        guard let amount = self.account.currentBalanceAmount else { return NSAttributedString(string: "") }
        let font = UIFont.santander(family: .text, type: .regular, size: 22)
        let moneyDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }
}

protocol BillAccountSelectorViewProtocol: AnyObject {
    func setViewModels(_ viewModels: [BillAccountSelectionViewModel])
}

class BillAccountSelectorViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    let presenter: BillAccountSelectorPresenterProtocol
    private var viewModels: [BillAccountSelectionViewModel] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: BillAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setupNavigationBar()
        self.setTableView()
        self.presenter.viewDidLoad()
    }
}

private extension BillAccountSelectorViewController {
    func setTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        let topInset: CGFloat = 14.0
        let bottomInset: CGFloat = 10.0
        self.tableView.contentInset.top = topInset
        self.tableView.contentInset.bottom = bottomInset
        self.tableView.register(AccountSelectionTableViewCell.self, bundle: AccountSelectionTableViewCell.bundle)
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_originAccount",
                                    header: .title(key: "toolbar_title_receiptsAndTaxes", style: .default))
        )
        .setRightActions(.close(action: #selector(didSelectDismiss)))
        .setLeftAction(.back(action: #selector(didSelectDismiss)))
        builder.build(on: self, with: nil)
        self.view.backgroundColor = UIColor.skyGray
    }
    
    @objc func didSelectDismiss() {
        self.presenter.didSelectDismiss()
    }
}

extension BillAccountSelectorViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accessibilityIdentifier = AccesibilityBills.LastBillFilterSelectionAccount.selectionAccountFilter
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: AccountSelectionTableViewCell.identifier, for: indexPath) as? AccountSelectionTableViewCell else { return UITableViewCell() }
        cell.setViewModel(self.viewModels[indexPath.row], accessibilityIdendtifier: accessibilityIdentifier)
        cell.accessibilityIdentifier = accessibilityIdentifier
        return cell
    }
}

extension BillAccountSelectorViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectAccount(self.viewModels[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setHighlighted()
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AccountSelectionTableViewCell else { return }
        cell.setUnhighlighted()
    }
}

extension BillAccountSelectorViewController: BillAccountSelectorViewProtocol {
    func setViewModels(_ viewModels: [BillAccountSelectionViewModel]) {
        self.viewModels = viewModels
        self.tableView.reloadData()
    }
}
