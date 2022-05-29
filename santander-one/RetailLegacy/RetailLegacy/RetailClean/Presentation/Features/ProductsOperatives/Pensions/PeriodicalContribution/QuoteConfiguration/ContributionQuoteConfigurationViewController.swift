import UIKit

protocol ContributionQuoteConfigurationPresenterProtocol: Presenter {
    func selectedConfigurationItem(index: Int)
    func setDate(date: Date, atIndex index: Int)
    func confirmButtonTouched()
}

class ContributionQuoteConfigurationViewController: BaseViewController<ContributionQuoteConfigurationPresenterProtocol> {
    
    override class var storyboardName: String {
        return "PlansOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    var confirmButtonTitle: LocalizedStylableText? {
        didSet {
            if let text = confirmButtonTitle {
                confirmButton.set(localizedStylableText: text, state: .normal)
            } else {
                confirmButton.setTitle(nil, for: .normal)
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var confirmButton: RedButton!
    
    private lazy var dataSource: DatePickerTableDataSource = {
        let dataSource = DatePickerTableDataSource()
        dataSource.delegate = self
        dataSource.pickerDelegate = self
        
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["PlanQuoteConfigurationItemTableViewCell", "PlanQuoteConfigurationDateItemTableViewCell", "GenericHeaderViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
        
        bottomSeparator.backgroundColor = .lisboaGray
        
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
    
    func hideInputViews() {
        dataSource.resignDatePickerFirstResponder()
    }
}

extension ContributionQuoteConfigurationViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectedConfigurationItem(index: indexPath.row)
    }
}

extension ContributionQuoteConfigurationViewController: DatePickerTableDataSourceDelegate {
    func valueChanged(date: Date, indexPath: IndexPath) {
        presenter.setDate(date: date, atIndex: indexPath.row)
    }
}
