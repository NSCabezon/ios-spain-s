import UI
import CoreFoundationLib

protocol InboxNotificationViewProtocol: class, LoadingViewPresentationCapable {
    func didLoadNotifications(viewModel: [PushNotificationViewModel]?)
    func didDeleteNotifications()
    func didDeleteNotification(atIndex index: Int)
    func markAsRead(atIndex index: Int)
}

final class InboxNotificationViewController: UIViewController {
    @IBOutlet weak var confirmButton: RedLisboaButton! {
        didSet {
            confirmButton.setTitle(localized("notifications_button_deleteNotifications"), for: .normal)
            confirmButton.addSelectorAction(target: self, #selector(buttonDidPressed))
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    private let presenter: InboxNotificationPresenterProtocol
    
    private let cellAllIdentifier = "CheckNotificationTableViewCell"
    private let cellIdentifier = "NotificationTableViewCell"
    private let cellHeaderIdentifier = "NotificationHeaderTableViewCell"
    private let cellEmptyIdentifier = "CheckNotificationEmtpyTableViewCell"
    private var notificationArray: [PushNotificationViewModel] = []
    private var showHeader = true
    private var didFinishLoading: Bool = false
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: InboxNotificationPresenterProtocol, showHeader: Bool) {
        self.presenter = presenter
        self.showHeader = showHeader
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        presenter.viewWillAppear()
    }
    
    private func setupView() {
        self.view.backgroundColor = UIColor.bg
        buttonHeightConstraint.constant = 0
    }
    
    // MARK: - Helpers
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_notifications")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func dismissViewController() {
        presenter.dismissViewController()
    }
    
    @objc private func openMenu() {
        presenter.openMenu()
    }
    
    func registerCell() {
        tableView.register(UINib(nibName: cellAllIdentifier, bundle: Bundle.module),
                           forCellReuseIdentifier: cellAllIdentifier)
        tableView.register(UINib(nibName: cellIdentifier, bundle: Bundle.module),
                           forCellReuseIdentifier: cellIdentifier)
        tableView.register(UINib(nibName: cellHeaderIdentifier, bundle: Bundle.module),
                           forCellReuseIdentifier: cellHeaderIdentifier)
        tableView.register(UINib(nibName: cellEmptyIdentifier, bundle: Bundle.module), forCellReuseIdentifier: cellEmptyIdentifier)
    }
    
    @objc private func buttonDidPressed() {
        let notifications = notificationArray.filter { $0.isCheckSelected == true  }
        let entities = notifications.map { $0.entity }
        presenter.deleteNotifications(notifications: entities)
    }
    
    func didDeleteNotifications() {
        notificationArray.removeAll(where: { $0.isCheckSelected == true })
        checkSelectedNotification()
        tableView.reloadData()
    }
    
    func didDeleteNotification(atIndex index: Int) {
        notificationArray.remove(at: index)
        checkSelectedNotification()
        tableView.reloadData()
    }
    
    private func checkSelectedNotification() {
        let checked = notificationArray.map { $0.isCheckSelected }.contains(true) && !notificationArray.isEmpty
        buttonHeightConstraint.constant = checked ? 80 : 0
        confirmButton.setNeedsDisplay()
    }
}

extension InboxNotificationViewController: InboxNotificationViewProtocol {
    var associatedLoadingView: UIViewController {
        self
    }
    
    func didLoadNotifications(viewModel: [PushNotificationViewModel]?) {
        guard let viewModel = viewModel else { return }
        notificationArray = viewModel
        didFinishLoading = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension InboxNotificationViewController: NotificationHeaderTableViewCellDelegate {
    func didTapLocation() {
        presenter.didSelectOffer()
    }
}

extension InboxNotificationViewController: CheckNotificationTableViewCellDelegate {
    func didTapCheckAll(isOn: Bool) {
        for noti in notificationArray {
            noti.setCheck(isOn: isOn)
        }
        checkSelectedNotification()
        tableView.reloadData()
        self.presenter.trackClickAll()
    }
}

extension InboxNotificationViewController: NotificationTableViewCellDelegate {
    func didTapCheck(isOn: Bool, index: Int) {
        notificationArray[index].checkChanged()
        checkSelectedNotification()
        tableView.reloadData()
    }
    
    func tapDeleteNotification(index: Int) {
        let viewModel = notificationArray[index]
        presenter.deleteSwipe(notificationViewModel: viewModel)
        let indexNoti = index + 2
        notificationArray.remove(at: index)
        tableView.reloadData()
        checkSelectedNotification()
    }
    
    func swipeIsActivated(_ activated: Bool, atIndex index: Int) {
        notificationArray[index].isSwiped = activated
    }
}

extension InboxNotificationViewController: UITableViewDataSource, UITableViewDelegate {
    
    private var numberOfRows: Int {
        guard notificationArray.count != 0 else { return showHeader ? 3 : 2 }
        return showHeader ? notificationArray.count + 2  : notificationArray.count + 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return showHeader ? dataWithHeader(tableView: tableView, indexPath: indexPath) :
            dataWithoutHeader(tableView: tableView, indexPath: indexPath)
    }
    
    private func dataWithHeader(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellHeaderIdentifier, for: indexPath) as? NotificationHeaderTableViewCell
            cell?.setTitle(localized("mailbox_link_settingAlert"))
            cell?.delegate = self
            return cell ?? UITableViewCell()
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellAllIdentifier, for: indexPath) as? CheckNotificationTableViewCell
            cell?.delegate = self
            cell?.setTitle(localized("notifications_title_notifications"))
            let uncheck = notificationArray.map { $0.isCheckSelected }.contains(false)
            if uncheck { cell?.uncheck() }
            cell?.hideCheckButton(notificationArray.count == 0)
            return cell ?? UITableViewCell()
        } else {
            if notificationArray.count == 0 {
                guard didFinishLoading else { return UITableViewCell() }
                let cell = tableView.dequeueReusableCell(withIdentifier: cellEmptyIdentifier, for: indexPath) as? CheckNotificationEmtpyTableViewCell
                cell?.set(title: localized("emptyMailbox_label_notFilingBank"),
                          subtitle: localized("emptyMailbox_text_notFilingBank"))
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell
                let index = indexPath.row - 2
                cell?.setCellInfo(notificationArray[index], index: index)
                cell?.setDeleteOption(title: localized("generic_button_delete"))
                cell?.setSwipeProperly(notificationArray[index].isSwiped)
                cell?.delegateNotification = self
                
                return cell ?? UITableViewCell()
            }
        }
    }
    
    private func dataWithoutHeader(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: cellAllIdentifier, for: indexPath) as? CheckNotificationTableViewCell
            else { return UITableViewCell() }
            cell.delegate = self
            cell.setTitle(localized("notifications_title_notifications"))
            let uncheck = notificationArray.map { $0.isCheckSelected }.contains(false)
            if uncheck { cell.uncheck() }
            cell.hideCheckButton(notificationArray.count == 0)
            return cell
        } else {
            if notificationArray.count == 0 {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellEmptyIdentifier, for: indexPath) as? CheckNotificationEmtpyTableViewCell, didFinishLoading
                else { return UITableViewCell() }
                cell.set(title: localized("emptyMailbox_label_notFilingBank"),
                         subtitle: localized("emptyMailbox_text_notFilingBank"))
                return cell
            } else {
                guard
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell
                else { return UITableViewCell() }
                let index = indexPath.row - 1
                cell.setCellInfo(notificationArray[index], index: index)
                cell.setDeleteOption(title: localized("generic_button_delete"))
                cell.setSwipeProperly(notificationArray[index].isSwiped)
                cell.delegateNotification = self
                
                return cell ?? UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = showHeader ? indexPath.row - 2 : indexPath.row - 1
        guard notificationArray.count > index, index >= 0 else { return }
        let viewModel = notificationArray[index]
        self.presenter.showDetail(for: viewModel, atIndex: index)
    }
    
    func markAsRead(atIndex index: Int) {
        let viewModel = notificationArray[index]
        viewModel.markAsRead()
        tableView.reloadData()
    }
}

extension InboxNotificationViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
