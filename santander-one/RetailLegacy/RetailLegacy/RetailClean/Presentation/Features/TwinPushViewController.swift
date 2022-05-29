import UIKit

protocol TwinPushPresenterProtocol: Presenter {
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
}

class TwinPushViewController: BaseViewController<TwinPushPresenterProtocol> {
    
    override class var storyboardName: String {
        return "Mailbox"
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerDeleteMultipleView: DeleteMultipleView!    
    weak var deleteMultipleView: DeleteMultipleView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var sections: [TableModelViewSection] = [] {
        didSet {
            dataSource.clearSections()
            dataSource.addSections(sections)
            tableView.reloadData()
        }
    }
    
    private lazy var dataSource: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    func clearSections() {
        sections.removeAll()
    }
        
    func currentSections() -> [TableModelViewSection] {
        return dataSource.sections
    }
    
    func itemsSectionContent() -> [AnyObject] {
        return dataSource.sections[0].items
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
        tableView.registerCells(["PushNotificationTableViewCell", "EmptyViewCell"])
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

extension TwinPushViewController: TableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selected(index: indexPath.row)
    }
}

extension TwinPushViewController: DeleteMultipleViewDelegate {
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
