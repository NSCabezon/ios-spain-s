import UIKit

protocol OrderTypeSelectorPresenterProtocol: Presenter {
    func tooltip(atIndex index: Int) -> (title: LocalizedStylableText, description: LocalizedStylableText)
    func selectedType(index: Int)
    func confirmButtonTouched()
    func headerLoaded(model: StockBaseHeaderViewModel)
}

class OrderTypeSelectorViewController: BaseViewController<OrderTypeSelectorPresenterProtocol> {    
    override class var storyboardName: String {
        return "StockOperatives"
    }
    
    var headerViewModel: StockBaseHeaderViewModel? {
        didSet {
            guard let viewModel = headerViewModel else { return }
            presenter.headerLoaded(model: viewModel)
        }
    }
    lazy var radio: RadioTable = RadioTable(delegate: self)
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
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericHeaderViewCell", "RadioTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
        
        bottomSeparator.backgroundColor = .lisboaGray
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
}

extension OrderTypeSelectorViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        radio.didSelectCellComponent(indexPath: indexPath)
        presenter.selectedType(index: indexPath.row)
    }
}

extension OrderTypeSelectorViewController: RadioTableDelegate {
    var tableComponent: UITableView {
        return tableView
    }
    
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void) {
        let tooltip = presenter.tooltip(atIndex: tag)
        completion(.toolTip(title: tooltip.title, description: nil, localizedDesription: tooltip.description, delegate: self))
    }
}

extension OrderTypeSelectorViewController: ToolTipDisplayer {}

extension OrderTypeSelectorViewController: TradeOperativeViewControllerProtocol {}
