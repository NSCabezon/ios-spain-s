import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol ContactListViewControllerProtocol: DialogViewPresentationCapable {
    var contactListViewModels: [BizumContactListViewModel]? { get }
    func showContacts(_ contacts: [BizumContactListViewModel])
    func showSearchContacts(_ contacts: [BizumContactListViewModel])
    func setState(_ state: ContactListViewState)
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
}

enum ContactListViewState {
    case initial
    case empty
    case searching
}

final class ContactListViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchTextField: UIView!
    @IBOutlet weak private var superTitleBarLabel: UILabel!
    @IBOutlet weak private var titleBarLabel: UILabel!
    @IBOutlet weak private var barImageView: UIImageView!
    @IBOutlet weak private var closeButton: UIButton!
    private let presenter: ContactListPresenterProtocol
    private var state: ContactListViewState = .initial
    private var viewModels: [BizumContactListViewModel] = []
    private var searchedViewModels: [BizumContactListViewModel] = []
    private var searchTerm: String?
    private lazy var searchHeaderView: SearchHeaderView = {
        let view = SearchHeaderView()
        view.updateTitle(localized("bizum_hint_search").text)
        view.accessibilityIdentifier = AccessibilityBizumContact.bizumInputSearch
        view.delegate = self
        return view
    }()

    // MARK: - UIInterfaceOrientationMask
    /// shouldAutorotate isn't  needed

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: ContactListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(presenter: ContactListPresenterProtocol) {
        self.init(nibName: "ContactListViewController", bundle: .module, presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupTableView()
        self.presenter.viewDidLoad()
    }
}

private extension ContactListViewController {
    func setupView() {
        self.setupNavigationBar()
        self.addSearchTextView()
    }
    
    func addSearchTextView() {
        self.searchTextField.addSubview(self.searchHeaderView)
        self.searchHeaderView.fullFit()
    }
    
    func setupNavigationBar() {
        self.superTitleBarLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .mediumSanGray)
        self.titleBarLabel.setSantanderTextFont(type: .bold, size: 18.0, color: .santanderRed)
        self.barImageView.image = ESAssets.image(named: "icnBizumHeader")
        self.closeButton.setImageName("icnClose", withTintColor: .santanderRed)
        self.closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        self.closeButton.isUserInteractionEnabled = true
        self.view.backgroundColor = .skyGray
        self.superTitleBarLabel.set(localizedStylableText: localized("toolbar_title_bizum").uppercased())
        self.superTitleBarLabel.accessibilityIdentifier = AccessibilityBizumContact.bizumSuperTitleBarLabel
        self.titleBarLabel.set(localizedStylableText: localized("generic_button_contactBook"))
        self.titleBarLabel.accessibilityIdentifier = AccessibilityBizumContact.bizumTitleBarLabel
    }
    
    @objc func closePressed() {
        self.dismiss(animated: true)
    }
    
    func setupTableView() {
        self.registerCell()
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 18.0))
        self.tableView.accessibilityIdentifier = AccessibilityBizumContact.bizumListContacts
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    func registerCell() {
        let nib = UINib(nibName: "BizumContactTableViewCell", bundle: Bundle.module)
        self.tableView.register(nib, forCellReuseIdentifier: "BizumContactTableViewCell")
        let emptyCell = UINib(nibName: "BizumEmptyTableViewCell", bundle: Bundle.module)
        self.tableView.register(emptyCell, forCellReuseIdentifier: "BizumEmptyTableViewCell")
    }
}

extension ContactListViewController: ContactListViewControllerProtocol {
    var associatedDialogView: UIViewController {
        self
    }
    var contactListViewModels: [BizumContactListViewModel]? {
        self.viewModels
    }
    
    func showContacts(_ contacts: [BizumContactListViewModel]) {
        self.viewModels = contacts
        self.tableView.reloadData()
    }
    
    func showSearchContacts(_ contacts: [BizumContactListViewModel]) {
        self.searchedViewModels = contacts
        self.tableView.reloadData()
    }
    
    func setState(_ state: ContactListViewState) {
        self.state = state
    }
}

extension ContactListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state {
        case .empty:
            return 1
        case .searching:
            return self.searchedViewModels.count
        case .initial:
            return self.viewModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state {
        case .empty:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumEmptyTableViewCell.identifier, for: indexPath) as? BizumEmptyTableViewCell else { return BizumEmptyTableViewCell() }
            cell.isUserInteractionEnabled = false
            cell.setSearchTerm(term: self.searchTerm)
            return cell
        case .searching:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumContactTableViewCell.identifier, for: indexPath) as? BizumContactTableViewCell else { return BizumContactTableViewCell() }
            let viewModel = self.searchedViewModels[indexPath.row]
            cell.configure(viewModel)
            cell.accessibilityIdentifier = AccessibilityBizumContact.bizumBtnContact + "\(indexPath.row)"
            return cell
        case .initial:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumContactTableViewCell.identifier, for: indexPath) as? BizumContactTableViewCell else { return BizumContactTableViewCell() }
            let viewModel = self.viewModels[indexPath.row]
            cell.configure(viewModel)
            cell.accessibilityIdentifier = AccessibilityBizumContact.bizumBtnContact + "\(indexPath.row)"
            return cell
        }
        return UITableViewCell()
    }
}

extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel: BizumContactListViewModel
        switch self.state {
        case .initial:
            viewModel = self.viewModels[indexPath.row]
        case .searching:
            viewModel = self.searchedViewModels[indexPath.row]
        case .empty:
            return
        }
        self.dismiss(animated: true) {
            self.presenter.didSelectRow(viewModel: viewModel)
        }
    }
}

extension ContactListViewController: SearchHeaderViewDelegate {
    func textFieldDidSet(text: String) {
        self.searchTerm = text
        self.presenter.textFieldDidSet(text: text)
    }

    func touchAction() {
        self.view.endEditing(true)
    }

    func clearIconAction() {
        self.view.endEditing(true)
        self.textFieldDidSet(text: "")
    }
}

extension ContactListViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.showLoading(completion: completion)
        }
    }

    func hideLoadingView(_ completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.dismissLoading(completion: completion)
        }
    }
}
