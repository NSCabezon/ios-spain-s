import UIKit
import UI

protocol InternalTransferInsertAmountPresenterProtocol: Presenter {
    var continueTitle: LocalizedStylableText { get }
    func setDate(date: Date, at indexPath: IndexPath)
    func next()
    func didSelect(indexPath: IndexPath)
}

class InternalTransferInsertAmountViewController: BaseViewController<InternalTransferInsertAmountPresenterProtocol>, TableDataSourceDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var continueButton: RedButton!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "InternalTransferOperative"
    }
        
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
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
    
    func reloadAndBottomSection(row: Int, section: Int, scrolling: Bool = true) {
        dataSource.clearDatePickers()
        tableView.reloadData()
        if scrolling {
            tableView.layoutIfNeeded()
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: true)
        }
    }
    
    func reloadPickerConfig(_ config: DatePickerControllerConfiguration, indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
        guard let datePickerCell = tableView.cellForRow(at: indexPath) as? DatePickerCell else { return }
        dataSource.updateConfig(config, for: datePickerCell)
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: DatePickerTableDataSource = {
        let dataSource = DatePickerTableDataSource()
        dataSource.delegate = self
        dataSource.pickerDelegate = self
        return dataSource
    }()
    
    // MARK: - Private methods
    
    @IBAction private func continueButtonTapped(_ sender: UIButton) {
        presenter.next()
    }
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        continueButton.set(localizedStylableText: presenter.continueTitle, state: .normal)
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["GenericHeaderViewCell", "AmountInputTableViewCell", "TextFieldTableViewCell", "OnePayTransferDestinationSegmentCell", "StockOrderValidityDateTableViewCell", "OptionsPickerTableViewCell", "RadioButtonCell", "RadioButtonAndDateCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelect(indexPath: indexPath)
    }
}

extension InternalTransferInsertAmountViewController: DatePickerTableDataSourceDelegate {
    func valueChanged(date: Date, indexPath: IndexPath) {
        presenter.setDate(date: date, at: indexPath)
    }
}
