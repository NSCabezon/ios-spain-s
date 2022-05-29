import UIKit

protocol SalesForcePresenterProtocol: Presenter {
    func showPresenterLoading(type: LoadingViewType)
    func hidePresenterLoading()
    func selected(index: Int)
    func selectAllNotifications()
    func editDeleteMode(activate: Bool)
    func delete()
    var selectAllText: LocalizedStylableText { get }
    var deleteText: LocalizedStylableText { get }
    var cancelText: LocalizedStylableText { get }
    var deleteButtonText: LocalizedStylableText { get }
    var indexSection: Int { get }
}

class SalesForceViewController: BaseViewController<SalesForcePresenterProtocol> {
    
    override class var storyboardName: String {
        return "Mailbox"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerDeleteMultipleView: UIView!
    weak var deleteMultipleView: DeleteMultipleView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
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
    
    func clearSections() {
        dataSource.clearSections()
    }
    
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func getItemsSectionContent(index: Int) -> [AnyObject] {
        return dataSource.sections[index].items
    }
    
    override func loadView() {
        super.loadView()
        if let deleteMultipleView = DeleteMultipleView.instantiateFromNib() {
            deleteMultipleView.embedInto(container: self.containerDeleteMultipleView)
            self.deleteMultipleView = deleteMultipleView
        }
    }
    
    override func prepareView() {
        super.prepareView()
        
        view.backgroundColor = .uiBackground
        tableView.separatorStyle = .none
        tableView.registerCells(["PushNotificationTableViewCell", "PushNotificationLocationTableViewCell", "EmptyViewCell", "OperativeLabelTableViewCell"])
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.estimatedRowHeight = 127.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        deleteMultipleView.delegate = self
        deleteMultipleView.buttonText = presenter.deleteButtonText
        deleteMultipleView.selectAllText = presenter.selectAllText
        deleteMultipleView.deleteText = presenter.deleteText
        deleteMultipleView.cancelText = presenter.cancelText
        deleteMultipleView.isHidden = true
        deleteMultipleView.setupViews()
    }
    
    func installLoading() {
        let type = LoadingViewType.onView(view: tableView, frame: nil, position: .center, controller: self)
        presenter.showPresenterLoading(type: type)
    }
    
    func removeLoading() {
        presenter.hidePresenterLoading()
    }
    
    func hideDeleteMultipleView(isHidden: Bool) {
        if isHidden {
            heightConstraint.constant = 0.0
            deleteMultipleView.isHidden = true
        } else {
            heightConstraint.constant = 81.0
            deleteMultipleView.isHidden = false
        }
    }
}

extension SalesForceViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == presenter.indexSection {
            presenter.selected(index: indexPath.row)
        }
    }
}

extension SalesForceViewController: DeleteMultipleViewDelegate {
    func selectAll() {
        presenter.selectAllNotifications()
    }
    
    func delete() {
        presenter.delete()
    }
    
    func editMode(activate: Bool) {
        presenter.editDeleteMode(activate: activate)
    }
}
