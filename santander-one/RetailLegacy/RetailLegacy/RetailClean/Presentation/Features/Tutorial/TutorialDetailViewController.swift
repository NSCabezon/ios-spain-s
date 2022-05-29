import UIKit

protocol TutorialDetailPresenterProtocol: Presenter {}

class TutorialDetailViewController: BaseViewController<TutorialDetailPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    lazy var dataSource: TableDataSource = {
        let data = TableDataSource()
        return data
    }()
  
    override class var storyboardName: String {
        return "Tutorial"
    }
    
    override func prepareView() {
        super.loadView()
        view.backgroundColor = .uiWhite
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerCells(["TutorialImageTableViewCell", "OperativeSeparatorTableViewCell", "OperativeLabelTableViewCell"])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
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
    
    func calculateHeight() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
