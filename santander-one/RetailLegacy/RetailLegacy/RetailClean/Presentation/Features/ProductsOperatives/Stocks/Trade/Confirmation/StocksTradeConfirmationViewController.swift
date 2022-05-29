import UIKit

protocol StocksTradeConfirmationPresenterProtocol: Presenter {
    func confirmButtonTouched()
    func headerLoaded(model: StockBaseHeaderViewModel)
}

class StocksTradeConfirmationViewController: BaseViewController<StocksTradeConfirmationPresenterProtocol> {
    
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
    
    private lazy var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericHeaderViewCell", "GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemViewCell", "OperativeLabelTableViewCell"])        
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
}

extension StocksTradeConfirmationViewController: TradeOperativeViewControllerProtocol {}
