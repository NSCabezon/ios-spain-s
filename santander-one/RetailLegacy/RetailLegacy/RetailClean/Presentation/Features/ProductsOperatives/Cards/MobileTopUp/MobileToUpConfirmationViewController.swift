//

import UIKit
import CoreFoundationLib

protocol MobileToUpConfirmationPresenterProtocol: Presenter {
    func confirmButtonTouched()
}

class MobileToUpConfirmationViewController: BaseViewController<MobileToUpConfirmationPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var confirmButton: RedButton!
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
    private lazy var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["CardConfirmationTableViewCell", "ConfirmationItemViewCell", "ConfirmationItemsListHeader", "GenericConfirmationTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .uiBackground
        confirmButton.accessibilityIdentifier = AccessibilityMobileRecharge.confirmationBtnContinue.rawValue
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
}
