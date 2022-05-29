//

import UIKit

protocol ChargeDischargeCardInputAmountPresenterProtocol: Presenter {
    func selectedType(index: Int)
    func continueButtonTouched()
}

class ChargeDischargeCardInputAmountViewController: BaseViewController<ChargeDischargeCardInputAmountPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var continueButton: RedButton!
    
    lazy var radio: RadioTable = RadioTable(delegate: self)

    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    func replaceItemAt(row: Int, newItem: AnyObject) {
        tableView.beginUpdates()
        sections[1].items[row] = newItem
        tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .automatic)
        tableView.endUpdates()
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
        tableView.registerCells(["GenericHeaderViewCell", "RadioTableViewCell", "MaxMinCellItem"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        continueButton.configureHighlighted(font: .latoMedium(size: 16))
    }
}

extension ChargeDischargeCardInputAmountViewController: RadioTableDelegate {
    var tableComponent: UITableView {
        return tableView
    }
    
    func auxiliaryButtonAction(tag: Int, completion: (RadioTableAuxiliaryAction) -> Void) {
    }
}

extension ChargeDischargeCardInputAmountViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        radio.didSelectCellComponent(indexPath: indexPath)
        presenter.selectedType(index: indexPath.row)
    }
}
