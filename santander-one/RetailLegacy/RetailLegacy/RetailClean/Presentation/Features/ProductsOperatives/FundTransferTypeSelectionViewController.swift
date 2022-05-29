import UIKit

protocol FundTransferTypeSelectionPresenterProtocol: Presenter {
    func selected(index: IndexPath)
    func onContinueButtonClicked()
}

class FundTransferTypeSelectionViewController: BaseViewController<FundTransferTypeSelectionPresenterProtocol> {
    
    override class var storyboardName: String {
        return "FundOperatives"
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
        dataSource.delegate = self
        
        return dataSource
    }()
    
    override func prepareView() {
        super.prepareView()
        tableView.separatorStyle = .none
        tableView.registerCells(["GenericHeaderViewCell", "SubscriptionOperativeLabelTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .uiBackground
        tableView.backgroundColor = .uiBackground
        
        continueButton.configureHighlighted(font: .latoBold(size: 16))
    }
}

extension FundTransferTypeSelectionViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath)
    }
}
