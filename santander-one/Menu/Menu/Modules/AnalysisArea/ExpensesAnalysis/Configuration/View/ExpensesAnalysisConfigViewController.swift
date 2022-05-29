import UIKit
import UI
import CoreFoundationLib

protocol ExpensesAnalysisConfigView: AnyObject {
    func setHeaderView(_ viewModel: ExpensesAnalysysConfigHeaderViewModel)
    func setAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel])
    func setCardViews(_ cardViewModels: [CardProductConfigCellViewModel])
    func reloadAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel])
    func reloadCardViews(_ cardViewModels: [CardProductConfigCellViewModel])
    func setOtherBanksViews(_ otherBanksViewModels: [OtherBankConfigViewModel])
    func showSaveChangesButton()
}

final class ExpensesAnalysisConfigViewController: UIViewController {
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var stackContainerView: UIStackView!
    private var tableView = BankProductsTableView()
    var presenter: ExpensesAnalysisConfigPresenterProtocol
    private lazy var saveChangesFooter: ExpensesAnalysisConfigSaveChangesView = {
        let view = ExpensesAnalysisConfigSaveChangesView()
        view.delegate = self
        return view
    }()
    
    init(presenter: ExpensesAnalysisConfigPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ExpensesAnalysisConfigViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFooterFrame()
    }
}

private extension ExpensesAnalysisConfigViewController {
    func setupView() {
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setTableView()
        self.setStackContainerView()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_setting")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    func setStackContainerView() {
        self.stackContainerView.addArrangedSubview(self.tableView)
        self.stackContainerView.addArrangedSubview(self.saveChangesFooter)
        self.saveChangesFooter.isHidden = true
    }
    
    func setTableView() {
        self.tableView.fullFit()
        self.tableView.setup()
        self.tableView.bankProductsTableViewDelegate = self
    }
    
    func updateFooterFrame() {
        guard let footerView = self.tableView.tableFooterView else {
            return
        }
        let width = self.tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tableView.tableFooterView = footerView
        }
    }
}

extension ExpensesAnalysisConfigViewController: ExpensesAnalysisConfigView {
    func setHeaderView(_ viewModel: ExpensesAnalysysConfigHeaderViewModel) {
        self.tableView.setHeader(viewModel)
    }
    
    func setAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel]) {
        self.tableView.setAccounts(accountViewModels: accountViewModels)
        self.tableView.reloadData()
    }
    
    func setCardViews(_ cardViewModels: [CardProductConfigCellViewModel]) {
        self.tableView.setCards(cardViewModels: cardViewModels)
        self.tableView.reloadData()
    }
    
    func reloadAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel]) {
        self.tableView.reloadAccounts(accountViewModels: accountViewModels)
        self.tableView.reloadData()
    }
    
    func reloadCardViews(_ cardViewModels: [CardProductConfigCellViewModel]) {
        self.tableView.reloadCards(cardViewModels: cardViewModels)
        self.tableView.reloadData()
    }
    
    func setOtherBanksViews(_ otherBanksViewModels: [OtherBankConfigViewModel]) {
        self.tableView.setOtherBanksConfigFooter(otherBanksViewModels)
    }
    
    func showSaveChangesButton() {
        self.saveChangesFooter.isHidden = false
    }
}

extension ExpensesAnalysisConfigViewController: BankProductsConfigDelegate {
    func didPressAllAccountsCheckBox(_ areAllSelected: Bool) {
        self.presenter.didPressAllAccountsCheckBox(areAllSelected)
    }
    
    func didPressAllCardsCheckBox(_ areAllSelected: Bool) {
        self.presenter.didPressAllCardsCheckBox(areAllSelected)
    }
    
    func didPressAccountCheckBox(_ viewModel: AccountProductConfigCellViewModel) {
        self.presenter.didPressAccountCheckBox(viewModel)
    }
    
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel) {
        self.presenter.didPressCardCheckBox(viewModel)
    }
    
    func didPressAddOtherBanks() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
        self.presenter.didPressAddOtherBanks()
    }
    
    func didPressOtherBankConfig(_ viewModel: OtherBankConfigViewModel) {
        self.presenter.didPressOtherBankConfig(viewModel)
    }
}

extension ExpensesAnalysisConfigViewController: ExpensesAnalysisConfigSaveChangesDelegate {
    func didPressSaveChanges() {
        self.presenter.didSelectSaveChanges()
    }
}
