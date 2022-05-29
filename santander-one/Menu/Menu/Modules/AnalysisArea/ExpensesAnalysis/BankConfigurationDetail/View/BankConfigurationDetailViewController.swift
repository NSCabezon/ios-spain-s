import UIKit
import UI
import CoreFoundationLib

protocol BankConfigurationDetailViewProtocol: AnyObject {
    func setHeaderView(_ viewModel: BankDetailProductsHeaderViewModel)
    func setAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel])
    func setCardViews(_ cardViewModels: [CardProductConfigCellViewModel])
    func reloadAccountViews(_ accountViewModels: [AccountProductConfigCellViewModel])
    func reloadCardViews(_ cardViewModels: [CardProductConfigCellViewModel])
    func recoveryKeysFinished()
    func showRemoveConnectionDialog()
    func showSaveChangesButton()
}

final class BankConfigurationDetailViewController: UIViewController {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var topSeparator: UIView!
    private var tableView = BankDetailProductsTableView()
    let presenter: BankConfigurationDetailPresenterProtocol
    private lazy var saveChangesFooter: BankConfigDetailFooterView = {
        let view = BankConfigDetailFooterView()
        view.delegate = self
        return view
    }()
    
    init(presenter: BankConfigurationDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "BankConfigurationDetail", bundle: .module)
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
        self.configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFooterFrame()
    }
}

private extension BankConfigurationDetailViewController {
    func configureNavigationBar() {
        NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_setting"))
            .setLeftAction(.back(action: #selector(didSelectBack)))
            .setRightActions(.close(action: #selector(didSelectDismiss)))
            .build(on: self, with: nil)
        topSeparator.backgroundColor = .mediumSkyGray
    }
    
    func setupView() {
        self.topSeparator.backgroundColor = .mediumSkyGray
        self.setTableView()
        self.setStackContainerView()
    }
    
    func setStackContainerView() {
        self.stackView.addArrangedSubview(self.tableView)
        self.stackView.addArrangedSubview(self.saveChangesFooter)
        self.saveChangesFooter.isHidden = true
    }
    
    func setTableView() {
        self.tableView.fullFit()
        self.tableView.setup()
        self.tableView.bankDetailProductsTableViewDelegate = self
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
    
    @objc func didSelectDismiss() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    func showDialog() {
        let allowAction = LisboaDialogAction(title: localized("generic_link_yes"), type: .red, margins: (left: 16.0, right: 8.0)) {
            self.presenter.didSelectConfirmRemoveConnection()
        }
        let refuseAction = LisboaDialogAction(title: localized("generic_link_no"), type: .white, margins: (left: 16.0, right: 8.0)) { }
        LisboaDialog(
            items: [
                .margin(22.0),
                .styledText(LisboaDialogTextItem(text: localized("analysis_label_sureRemoveConnection"),
                                                 font: .santander(family: .headline, type: .regular, size: 26),
                                                 color: .black,
                                                 alignament: .center,
                                                 margins: (16, 16))),
                .margin(9.0),
                .styledText(LisboaDialogTextItem(text: localized("analysis_text_sureRemoveConnection"),
                                                 font: .santander(family: .micro, type: .regular, size: 16),
                                                 color: .lisboaGray,
                                                 alignament: .center,
                                                 margins: (16, 16))),
                .margin(14.0),
                .horizontalActions(HorizontalLisboaDialogActions(left: refuseAction, right: allowAction))
            ],
            closeButtonAvailable: false
        ).showIn(self)
    }
}

extension BankConfigurationDetailViewController: BankConfigurationDetailViewProtocol {
    func setHeaderView(_ viewModel: BankDetailProductsHeaderViewModel) {
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
    
    func recoveryKeysFinished() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func showRemoveConnectionDialog() {
        self.showDialog()
    }
    
    func showSaveChangesButton() {
        self.saveChangesFooter.isHidden = false
    }
}

extension BankConfigurationDetailViewController: BankDetailProductsConfigDelegate {
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
    
    func didPressRemoveConnection() {
        self.presenter.didSelectRemoveConnection()
    }
    
    func didPressRecoveryKeys() {
        self.presenter.didSelectUpdateAccessKeys()
    }
}

extension BankConfigurationDetailViewController: BankConfigDetailFooterDelegate {
    func didPressSaveChanges() {
        self.presenter.didSelectSaveData()
    }
}
