//

import UIKit
import CoreFoundationLib

protocol ChargeDischargeCardAccountSelectionPresenterProtocol: Presenter {
    func selected(index: Int)
}

class ChargeDischargeCardAccountSelectionViewController: BaseViewController<ChargeDischargeCardAccountSelectionPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self

        return dataSource
    }()
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "SelectableProductViewCell"])         
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = AccessibilityCardChargeDischarge.title
    }
    
}

extension ChargeDischargeCardAccountSelectionViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath.row)
    }
}
