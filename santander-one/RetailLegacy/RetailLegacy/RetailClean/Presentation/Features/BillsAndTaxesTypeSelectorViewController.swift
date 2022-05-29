import UIKit
import CoreFoundationLib

protocol BillsAndTaxesTypeSelectorPresenterProtocol: Presenter {
    func onSelectedIndex(index: Int)
}

class BillsAndTaxesTypeSelectorViewController: BaseViewController<BillsAndTaxesTypeSelectorPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    
    var sections: [TableModelViewSection] {
        set {
            dataSource.clearSections()
            dataSource.addSections(newValue)
            tableView.reloadData()
        }
        get {
            return dataSource.sections
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    override func prepareView() {
        view.backgroundColor = .sanGreyLight
        tableView.separatorStyle = .none
        tableView.backgroundColor = .uiBackground
        tableView.registerCells(["GenericHeaderViewCell", "OnePayTransferSelectorSubtypeCell", "LinkWebViewTableViewCell"])
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 160.0
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
}

extension BillsAndTaxesTypeSelectorViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            presenter.onSelectedIndex(index: indexPath.row)
        }
    }
}

extension BillsAndTaxesTypeSelectorViewController: ForcedRotatable {
    func forcedOrientationForPresentation() -> UIInterfaceOrientation {
        return .portrait
    }
}
