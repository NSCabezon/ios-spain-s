//
//  BizumDonationNGOListViewController.swift
//  Bizum

import UIKit
import UI
import CoreFoundationLib
import ESUI

protocol BizumDonationNGOListViewProtocol: DialogViewPresentationCapable {
    func showAllOrganizationsList(_ organizations: [BizumNGOListViewModel])
    func setState(_ state: OrganizationsListViewState)
    func showFilteredOrganizations(_ organizations: [BizumNGOListViewModel])
    func showOrganizationLoading()
    func hideOrganizationLoading(state: OrganizationsListViewState)
}

enum OrganizationsListViewState {
    case initial
    case empty
    case searching
    case loading
}

final class BizumDonationNGOListViewController: UIViewController {
    let presenter: BizumDonationNGOListPresenterProtocol
    private var state: OrganizationsListViewState = .initial
    private var organizationViewModels: [BizumNGOListViewModel] = []
    private var filteredOrganizationViewModels: [BizumNGOListViewModel] = []
    private var searchTerm: String?
    @IBOutlet weak private var superTitleBarLabel: UILabel!
    @IBOutlet weak private var titleBarLabel: UILabel!
    @IBOutlet weak private var barImageView: UIImageView!
    @IBOutlet weak private var topSeparator: UIView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var searchTextField: UIView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var topTableViewSeparator: UIView!
    private lazy var searchHeaderView: BizumNGOSearchTextFieldView = {
        let view = BizumNGOSearchTextFieldView()
        view.backgroundColor = .white
        view.delegate = self
        return view
    }()
    
    private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: BizumDonationNGOListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(presenter: BizumDonationNGOListPresenterProtocol) {
        self.init(nibName: "BizumDonationNGOListViewController", bundle: .module, presenter: presenter)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupView()
        self.presenter.viewDidLoad()
        self.setAccessibilityIdentifiers()
    }
}

private extension BizumDonationNGOListViewController {
    func setupView() {
        self.setupNavigationBar()
        self.addSearchTextView()
        self.setupTableView()
    }

    func addSearchTextView() {
        self.searchTextField.addSubview(self.searchHeaderView)
        self.searchHeaderView.fullFit(topMargin: 10, bottomMargin: 0, leftMargin: 0, rightMargin: 0)
    }

    func setupNavigationBar() {
        self.view.backgroundColor = .skyGray
        topSeparator.backgroundColor = .mediumSkyGray
        self.titleBarLabel.setSantanderTextFont(type: .bold, size: 18.0, color: .santanderRed)
        self.titleBarLabel.set(localizedStylableText: localized("toolbar_title_organizations"))
        self.barImageView.image = ESAssets.image(named: "icnBizumHeader")
        self.closeButton.setImageName("icnClose", withTintColor: .santanderRed)
        self.closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        self.closeButton.isUserInteractionEnabled = true
        self.superTitleBarLabel.set(localizedStylableText: localized("toolbar_title_bizum").uppercased())
        self.superTitleBarLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .mediumSanGray)
    }

    @objc func closePressed() {
        self.dismiss(animated: true)
    }

    func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0))
        self.tableView.accessibilityIdentifier = AccessibilityBizumContact.bizumListContacts
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.registerTableViewCells()
        self.setupTopListSeparator()

    }
    
    func setupTopListSeparator() {
        self.topTableViewSeparator.layer.masksToBounds = false
        self.topTableViewSeparator.layer.masksToBounds = false
        self.topTableViewSeparator.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.topTableViewSeparator.layer.shadowColor = UIColor.clear.cgColor
        self.topTableViewSeparator.layer.shadowOpacity = 0.1
        self.topTableViewSeparator.layer.shadowRadius = 2.0
    }
    
    func registerTableViewCells() {
        tableView.register(UINib(nibName: BizumNGOTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumNGOTableViewCell.identifier)
        tableView.register(UINib(nibName: BizumNGOEmptyTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumNGOEmptyTableViewCell.identifier)
        tableView.register(UINib(nibName: BizumNGOSearchView.identifier,
                                 bundle: .module),
                           forHeaderFooterViewReuseIdentifier: BizumNGOSearchView.identifier)
        tableView.register(UINib(nibName: BizumNGOLoadingTableViewCell.identifier,
                                 bundle: .module),
                           forCellReuseIdentifier: BizumNGOLoadingTableViewCell.identifier)
    }
    
    func setAccessibilityIdentifiers() {
        self.tableView.accessibilityIdentifier = AccessibilityBizumDonation.ngoSelectorTableView
    }
}

extension BizumDonationNGOListViewController: BizumDonationNGOListViewProtocol {
    var associatedDialogView: UIViewController {
        self
    }
    
    func showAllOrganizationsList(_ organizations: [BizumNGOListViewModel]) {
        self.organizationViewModels = organizations
        self.tableView.reloadData()
    }
    
    func setState(_ state: OrganizationsListViewState) {
        self.state = state
    }
    
    func showFilteredOrganizations(_ organizations: [BizumNGOListViewModel]) {
        self.filteredOrganizationViewModels = organizations
        self.tableView.reloadData()
    }
    
    func showOrganizationLoading() {
        self.state = .loading
        self.searchHeaderView.disableView()
        self.tableView.reloadData()
    }
    
    func hideOrganizationLoading(state: OrganizationsListViewState) {
        self.state = state
        self.searchHeaderView.enableView()
        self.tableView.reloadData()
    }
}

// MARK: - TableView delegates
extension BizumDonationNGOListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state {
        case .empty:
            return 1
        case .searching:
            return self.filteredOrganizationViewModels.count
        case .initial:
            return self.organizationViewModels.count
        case .loading:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state {
        case .empty:
            return getNGOEmptyCell(indexPath)
        case .searching:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumNGOTableViewCell.identifier, for: indexPath) as? BizumNGOTableViewCell else { return BizumContactTableViewCell() }
            let viewModel = self.filteredOrganizationViewModels[indexPath.row]
            cell.configure(viewModel)
            return cell
        case .initial:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumNGOTableViewCell.identifier, for: indexPath) as? BizumNGOTableViewCell else { return BizumContactTableViewCell() }
            let viewModel = self.organizationViewModels[indexPath.row]
            cell.configure(viewModel)
            return cell
        case .loading:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BizumNGOLoadingTableViewCell.identifier, for: indexPath) as? BizumNGOLoadingTableViewCell else { return BizumContactTableViewCell() }
            cell.viewController = self
            cell.startLoading()
            return cell
        }
    }
    
    func getNGOEmptyCell(_ indexPath: IndexPath) -> UITableViewCell {
        guard let emptyCell = tableView.dequeueReusableCell(withIdentifier: BizumNGOEmptyTableViewCell.identifier, for: indexPath) as? BizumNGOEmptyTableViewCell else {
            return UITableViewCell()
        }
        let title: LocalizedStylableText = localized("bizum_title_emptyView")
        let message: LocalizedStylableText = localized("bizum_text_emptyView")
        emptyCell.setTitle(title, localizedMessageText: message)
        return emptyCell
    }
}

extension BizumDonationNGOListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let organizations: [BizumNGOListViewModel]
        switch state {
        case .initial:
            organizations = organizationViewModels
        case .searching:
            organizations = filteredOrganizationViewModels
        case .empty, .loading:
            organizations = []
        }
        guard organizations.indices.contains(indexPath.row) else { return }
        let organization: BizumNGOListViewModel = organizations[indexPath.row]
        self.presenter.didSelectOrganization(organization)
        self.closePressed()
    }
}

extension BizumDonationNGOListViewController: BizumNGOSearchTextFieldViewDelegate {
    func textFieldDidSet(text: String) {
        self.searchTerm = text
        self.presenter.organizationCodeDidSet(text: text)
    }
    
    func touchAction() {
        self.view.endEditing(true)
    }

    func clearIconAction() {
        self.view.endEditing(true)
        self.textFieldDidSet(text: "")
    }
}

extension BizumDonationAmountViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        Async.main {
            self.showLoading(completion: completion)
        }
    }

    func hideLoadingView(_ completion: (() -> Void)?) {
        Async.main {
            self.dismissLoading(completion: completion)
        }
    }
}

extension BizumDonationNGOListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topTableViewSeparator.layer.shadowColor = scrollView.contentOffset.y > 0.0 ? UIColor.black.cgColor : UIColor.clear.cgColor
    }
}
