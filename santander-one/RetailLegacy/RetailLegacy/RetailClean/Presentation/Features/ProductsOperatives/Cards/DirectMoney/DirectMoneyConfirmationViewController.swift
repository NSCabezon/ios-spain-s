//

import UIKit

protocol DirectMoneyConfirmationPresenterProtocol: Presenter {
    func confirmButtonTouched()
}

class DirectMoneyConfirmationViewController: BaseViewController<DirectMoneyConfirmationPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: RedButton!
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
        confirmButton.configureHighlighted(font: .latoBold(size: 16))
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
    }
    
    @IBAction func didTapConfirmButton(_ sender: Any) {
        presenter.confirmButtonTouched()
    }
}
