import UIKit

protocol PeriodicalContributionAmountPresenterProtocol: Presenter {
    func confirmButtonTouched()
}

class PeriodicalContributionAmountViewController: BaseViewController<PeriodicalContributionAmountPresenterProtocol> {
    
    override class var storyboardName: String {
        return "PlansOperatives"
    }
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var confirmButton: RedButton!
    
    var confirmButtonTitle: LocalizedStylableText? {
        didSet {
            confirmButton.set(localizedStylableText: confirmButtonTitle ?? .empty, state: .normal)
        }
    }
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        return dataSource
    }()
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[1].items
    }
    
    override func prepareView() {
        super.prepareView()
        
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "OperativeLabelTableViewCell", "AmountInputTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        
        bottomSeparator.backgroundColor = .lisboaGray
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        confirmButton.onTouchAction = { [weak self] button in
            self?.presenter.confirmButtonTouched()
        }
    }
}
