import UIKit

protocol PaymentMethodSubtypeSelectorPresenterProtocol: Presenter {
    func selected(_ index: Int)
}

class PaymentMethodSubtypeSelectorViewController: BaseViewController<PaymentMethodSubtypeSelectorPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    // MARK: - Private attributes
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    // MARK: - Public methods
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.registerCells(["PaymentMethodSubtypeCell", "OperativeLabelTableViewCell"])
        tableView.registerHeaderFooters([])
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
}

// MARK: - TableDataSourceDelegate

extension PaymentMethodSubtypeSelectorViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(indexPath.row)
    }
}
