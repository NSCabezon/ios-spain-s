import UIKit
import CoreFoundationLib

protocol ChargeDischargeCardConfirmationPresenterProtocol: Presenter {
    func confirmButtonTouched()
}

class ChargeDischargeCardConfirmationViewController: BaseViewController<ChargeDischargeCardConfirmationPresenterProtocol> {
    
    override class var storyboardName: String {
        return "CardsOperatives"
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
    @IBOutlet private weak var confirmButton: RedButton!
    
    private lazy var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none        
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericConfirmationTableViewCell", "DepositMoneyIntoCardHeaderConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        confirmButton.configureHighlighted(font: .latoMedium(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = AccessibilityCardChargeDischarge.confirmTitle
        confirmButton.accessibilityIdentifier = AccessibilityCardChargeDischarge.confirmConfirmBtn
    }
}
