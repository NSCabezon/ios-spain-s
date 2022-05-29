import UIKit

protocol ModifyDeferredTransferPresenterProtocol: Presenter {
    var continueButtonTitle: LocalizedStylableText { get }
    var title: String { get }
    func continueButtonDidSelected()
    func updateViewModelIbanPrefix(prefix: String)
}

class ModifyDeferredTransferViewController: BaseViewController<ModifyDeferredTransferPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    @IBOutlet private weak var separtorView: UIView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "ModifyDeferredTransfer"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? IBANTextFieldTableViewCell else {
                return
            }
            cell.prefixCalculationDelegate = self
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: DatePickerTableDataSource = {
        let dataSource = DatePickerTableDataSource()
        dataSource.pickerDelegate = self
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        navigationController?.navigationBar.setNavigationBarColor(.uiWhite)
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericHeaderViewCell", "AmountInputTableViewCell", "IBANTextFieldTableViewCell", "StockOrderValidityDateTableViewCell", "ModifyScheduledTransferDestinationCell", "GenericConfirmationTableViewCell", "TextFieldTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        view.backgroundColor = .uiWhite
        tableView.backgroundColor = .uiBackground
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.continueButtonTitle, state: .normal)
        separtorView.backgroundColor = .lisboaGray
        title = presenter.title
    }
    
    // MARK: - Private methods
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        presenter.continueButtonDidSelected()
    }
}

// MARK: - TableDataSourceDelegate

extension ModifyDeferredTransferViewController: DatePickerTableDataSourceDelegate {
    
    func valueChanged(date: Date, indexPath: IndexPath) { }
}

extension ModifyDeferredTransferViewController: PrefixCalculationDelegate {
    func ibanPrefixUpdated(updatedPrefix: String) {
        presenter.updateViewModelIbanPrefix(prefix: updatedPrefix)
    }
}
