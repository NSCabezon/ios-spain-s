//

import UIKit

protocol InternalTransferAccountDestinationSelectionPresenterProtocol: Presenter {
    func selected(index: Int)
}

class InternalTransferAccountDestinationSelectionViewController: BaseViewController<InternalTransferAccountDestinationSelectionPresenterProtocol> {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Public attributes
    
    override class var storyboardName: String {
        return "InternalTransferOperative"
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
        tableView.registerCells(["GenericHeaderViewCell", "SelectableProductViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
    }
}

extension InternalTransferAccountDestinationSelectionViewController: TableDataSourceDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath.row)
    }
}
