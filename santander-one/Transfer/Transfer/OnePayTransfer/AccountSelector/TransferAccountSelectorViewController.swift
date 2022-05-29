import UIKit
import UI
import CoreFoundationLib

public protocol TransferAccountSelectorViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func showAccounts(accountVisibles: [TransferAccountItemViewModel], accountNotVisibles: [TransferAccountItemViewModel])
}

public class TransferAccountSelectorViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
            
    let presenter: TransferAccountSelectorPresenterProtocol
    private var accountVisibles: [TransferAccountItemViewModel] = []
    private var accountNotVisibles: [TransferAccountItemViewModel] = []
    private var isVisibleHiddenCells: Bool = false
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TransferAccountSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(presenter: TransferAccountSelectorPresenterProtocol) {
        self.init(nibName: "TransferAccountSelectorViewController", bundle: .module, presenter: presenter)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.presenter.viewDidAppear()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTableHeaderView()
    }
    
    func setupView() {
        self.view.backgroundColor = .white
        self.tableView.register(StandardAccountSelectionTableViewCell.self, bundle: .uiModule)
        self.tableView.register(LabelArrowTableViewCell.self, bundle: LabelArrowTableViewCell.bundle)
    }
}

extension TransferAccountSelectorViewController: TransferAccountSelectorViewProtocol {
    public func showAccounts(accountVisibles: [TransferAccountItemViewModel], accountNotVisibles: [TransferAccountItemViewModel]) {
        self.accountVisibles = accountVisibles
        self.accountNotVisibles = accountNotVisibles
        self.tableView.reloadData()
    }
}

extension TransferAccountSelectorViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.isNotVisibles() ? (self.isVisibleHiddenCells ? 3 : 2) : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let index = "_row_\(indexPath.row)_section_\(indexPath.section)"
        switch indexPath.section {
        case 0:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "StandardAccountSelectionTableViewCell", for: indexPath) as? StandardAccountSelectionTableViewCell
            (cell as? StandardAccountSelectionTableViewCell)?.setup(with: self.accountVisibles[indexPath.row])
            (cell as? StandardAccountSelectionTableViewCell)?.setAccessibilityIdentifiersWithindex(index)
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "LabelArrowTableViewCell", for: indexPath) as? LabelArrowTableViewCell
            (cell as? LabelArrowTableViewCell)?.setAccountCellInfo(LabelArrowViewItem(numberPlaceHolder: self.accountNotVisibles.count))
            (cell as? LabelArrowTableViewCell)?.setAccessibilityIdentifiersWithindex(index)
        case 2:
            cell = self.tableView.dequeueReusableCell(withIdentifier: "StandardAccountSelectionTableViewCell", for: indexPath) as? StandardAccountSelectionTableViewCell
            (cell as? StandardAccountSelectionTableViewCell)?.setup(with: self.accountNotVisibles[indexPath.row])
            (cell as? StandardAccountSelectionTableViewCell)?.setAccessibilityIdentifiersWithindex(index)
        default:
            break
        }
        cell?.accessibilityIdentifier = AccessibilityTransferOrigin.cellButton.rawValue + index
        return cell ?? UITableViewCell()
    }
}

extension TransferAccountSelectorViewController: UITableViewDelegate {    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.presenter.didSelectAccount(self.accountVisibles[indexPath.row])
        case 1:
            self.updateCells()
        case 2:
            self.presenter.didSelectAccount(self.accountNotVisibles[indexPath.row])
        default:
            break
        }
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StandardAccountSelectionTableViewCell else { return }
        cell.setHighlighted()
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StandardAccountSelectionTableViewCell else { return }
        cell.setUnhighlighted()
    }
}

extension TransferAccountSelectorViewController {
    public var associatedLoadingView: UIViewController {
        return self
    }
}

private extension TransferAccountSelectorViewController {
    func updateCells() {
        self.isVisibleHiddenCells = !self.isVisibleHiddenCells
        if !self.isVisibleHiddenCells {
            self.tableView.deleteSections(IndexSet(integer: 2), with: .none)
        } else {
            self.tableView.insertSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    func isNotVisibles() -> Bool {
        return self.accountNotVisibles.count > 0
    }
    
    func addTableHeaderView() {
        guard self.tableView.tableHeaderView == nil else { return }
        self.tableView.layoutIfNeeded()
        let headerView = TransferAccountHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 200))
        self.tableView.tableHeaderView = headerView
        self.tableView.tableHeaderView?.layoutIfNeeded()
        headerView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.getCorrectHeight())
    }
}
