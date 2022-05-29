import UIKit

protocol StocksTradeOperativeCCVSelectorPresenterProtocol: Presenter {
    func selected(index: Int, ofSection section: Int)
    func headerLoaded(model: StockBaseHeaderViewModel)
}

class StocksTradeOperativeCCVSelectorViewController: BaseViewController<StocksTradeOperativeCCVSelectorPresenterProtocol>, TableDataSourceDelegate {
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
    lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericHeaderViewCell", "SelectableProductViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath.row, ofSection: indexPath.section)
    }
}

extension StocksTradeOperativeCCVSelectorViewController: TradeOperativeViewControllerProtocol {}
