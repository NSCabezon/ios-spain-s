//

import UIKit

protocol DirectMoneyInputPresenterProtocol: Presenter {
}

class DirectMoneyInputViewController: BaseViewController<DirectMoneyInputPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerButton: UIView!
    @IBOutlet weak var continueButton: RedButton!
    
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
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
}
