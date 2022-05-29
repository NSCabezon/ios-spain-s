import UIKit

protocol QuoteConfigurationItemsSelectionPresenterProtocol: Presenter {
    func selectedConfigurationItem(index: Int)
    func confirmButtonTouched()
}

class QuoteConfigurationItemsSelectionViewController: BaseViewController<QuoteConfigurationItemsSelectionPresenterProtocol> {
    
    override class var storyboardName: String {
        return "PlansOperatives"
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
    @IBOutlet private weak var separator: UIView!
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
        tableView.registerCells(["PlanQuoteConfigurationItemTableViewCell", "PlanQuoteConfigurationDateItemTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 65.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
        
        separator.backgroundColor = .lisboaGray
        
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
}

extension QuoteConfigurationItemsSelectionViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        radio.didSelectCellComponent(indexPath: indexPath)
        presenter.selectedConfigurationItem(index: indexPath.row)
    }
}

extension QuoteConfigurationItemsSelectionViewController: RadioTableDelegate {
    var tableComponent: UITableView {
        return tableView
    }
    
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void) {
        presenter.selectedConfigurationItem(index: tag)
    }
}
