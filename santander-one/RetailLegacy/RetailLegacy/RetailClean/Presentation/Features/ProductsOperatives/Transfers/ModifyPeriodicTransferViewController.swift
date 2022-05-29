import UIKit

protocol ModifyPeriodicTransferPresenterProtocol: Presenter {
    var continueButtonTitle: LocalizedStylableText { get }
    var title: String { get }
    func continueButtonDidSelected()
    func didSelect(indexPath: IndexPath)
    func dateChanged(indexPath: IndexPath, date: Date)
    func updateViewModelIbanPrefix(prefix: String)
}

class ModifyPeriodicTransferViewController: BaseViewController<ModifyPeriodicTransferPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    @IBOutlet private weak var separtorView: UIView!
    private var optionsPickerDelegateAndDataSource: OptionsPickerDelegateAndDataSource?
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "ModifyPeriodicTransfer"
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
        dataSource.delegate = self
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        navigationController?.navigationBar.setNavigationBarColor(.uiWhite)
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericHeaderViewCell", "AmountInputTableViewCell", "IBANTextFieldTableViewCell", "StockOrderValidityDateTableViewCell", "ModifyScheduledTransferDestinationCell", "GenericConfirmationTableViewCell", "TextFieldTableViewCell", "RadioButtonCell", "RadioButtonAndDateCell", "OptionsPickerTableViewCell"])
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
    
    func reload() {
        dataSource.clearDatePickers()
        tableView.reloadData()
    }
    
    func reloadAndSection(section: Int, scrolling: Bool = true) {
        tableView.reloadData()
        if scrolling {
            tableView.layoutIfNeeded()
            tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
        }
    }
    
    func reloadPickerConfig(_ config: DatePickerControllerConfiguration, indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
        guard let datePickerCell = tableView.cellForRow(at: indexPath) as? DatePickerCell else { return }
        dataSource.updateConfig(config, for: datePickerCell)
    }
    
    // MARK: - Private methods
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        presenter.continueButtonDidSelected()
    }
}

// MARK: - TableDataSourceDelegate

extension ModifyPeriodicTransferViewController: DatePickerTableDataSourceDelegate {
    
    func valueChanged(date: Date, indexPath: IndexPath) {
        presenter.dateChanged(indexPath: indexPath, date: date)
    }
}

extension ModifyPeriodicTransferViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelect(indexPath: indexPath)
    }
}

extension ModifyPeriodicTransferViewController: PrefixCalculationDelegate {
    func ibanPrefixUpdated(updatedPrefix: String) {
        presenter.updateViewModelIbanPrefix(prefix: updatedPrefix)
    }
}
