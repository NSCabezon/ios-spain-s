import UIKit

protocol ExtraordinaryContributionConfirmationPresenterProtocol: Presenter {
    func confirmButtonTouched()
}

class ExtraordinaryContributionConfirmationViewController: BaseViewController<ExtraordinaryContributionConfirmationPresenterProtocol> {
    
    override class var storyboardName: String {
        return "PlansOperatives"
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
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var confirmButton: RedButton!
    
    private lazy var dataSource: TableDataSource = {
        return TableDataSource()
    }()
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerHeaderFooters(["TitledTableHeader"])
        tableView.registerCells(["GenericConfirmationTableViewCell", "ConfirmationItemsListHeader", "ConfirmationItemViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedSectionHeaderHeight = 50.0
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .uiBackground
        
        bottomSeparator.backgroundColor = .lisboaGray
        
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
}
