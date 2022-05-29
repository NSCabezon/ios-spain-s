import UIKit

protocol OrderTitlesAndDatePresenterProtocol: Presenter {
    func setDate(date: Date, atSection section: Int)
    func confirmButtonTouched()
    func headerLoaded(model: StockBaseHeaderViewModel)
}

class OrderTitlesAndDateViewController: BaseViewController<OrderTitlesAndDatePresenterProtocol>, TableDataSourceDelegate {
    override class var storyboardName: String {
        return "StockOperatives"
    }
    
    var headerViewModel: StockBaseHeaderViewModel? {
        didSet {            
            guard let viewModel = headerViewModel else { return }
            presenter.headerLoaded(model: viewModel)
        }
    }
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    private lazy var dataSource: DatePickerTableDataSource = {
        let dataSource = DatePickerTableDataSource()
        dataSource.delegate = self
        dataSource.pickerDelegate = self
        
        return dataSource
    }()
    
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
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none        
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericHeaderViewCell", "StockOrderValidityDateTableViewCell", "FormatedTextFieldTableViewCell", "OperativeLabelTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
        
        bottomSeparator.backgroundColor = .lisboaGray
        
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension OrderTitlesAndDateViewController: DatePickerTableDataSourceDelegate {
    func valueChanged(date: Date, indexPath: IndexPath) {
        presenter.setDate(date: date, atSection: indexPath.section)
    }
}

extension OrderTitlesAndDateViewController: TradeOperativeViewControllerProtocol {}
