//
//  SecurityModuleViewController.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import CoreFoundationLib
import UIKit
import UI

protocol SecurityViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    var presenter: SecurityPresenterProtocol { get }
    func setCellsInfo(_ cellsInfo: [CellInfo])
    func showComingSoonToast()
    func addLastAccessCell(_ cell: CellInfo)
    func showBiometryMessage(localizedKey: String, biometryType: BiometryTypeEntity)
    func showBiometryAlert(localizedKey: String, biometryText: String)
}

final class SecurityModuleViewController: UIViewController {
    
    @IBOutlet weak var header: PersonalAreaInfoHeader?
    @IBOutlet weak var tableView: UITableView?
    
    let presenter: SecurityPresenterProtocol
    let biometryViewHelper: BiometryViewHelper
    
    private var controller: PersonalAreaTableViewControllerProtocol? {
        didSet {
            controller?.setDelegate(presenter as? (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate))
            controller?.setCustomDelegate(presenter as? PersonalAreaCustomActionCellDelegate)
        }
    }
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    init(dependenciesResolver: DependenciesResolver, presenter: SecurityPresenterProtocol) {
        self.presenter = presenter
        self.biometryViewHelper = BiometryViewHelper(dependenciesResolver: dependenciesResolver)
        super.init(nibName: "SecurityModuleViewController", bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        presenter.viewBecomeActive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: self
        )
    }
    
    @objc func searchButtonPressed() { presenter.searchAction() }
}

private extension SecurityModuleViewController {
    func commonInit() {
        self.header?.setImage(PersonalAreaSection.security.image(),
                         description: PersonalAreaSection.security.desc())
        self.configureTableView()
        self.initializeController()
        self.setAccessibilityIdentifiers()
    }
    
    func configureTableView() {
        self.view.backgroundColor = UIColor.white
        self.tableView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = .none
    }
    
    func initializeController() {
        self.controller = PersonalAreaTableViewController(tableView: tableView)
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: PersonalAreaSection.security.title())
        )
        builder.setLeftAction(.back(action: #selector(backButtonPressed)))
        builder.setRightActions(.menu(action: #selector(drawerPressed)))
        builder.build(on: self, with: self.presenter)
    }
    
    func setAccessibilityIdentifiers() {
        self.header?.accessibilityIdentifier = AccessibilitySecuritySectionPersonalArea.securitySectionViewHeader
    }
    
    @objc func becomeActive() { presenter.viewBecomeActive() }
    @objc func backButtonPressed() { presenter.backButtonAction() }
    @objc func drawerPressed() { presenter.drawerAction() }
}

extension SecurityModuleViewController: SecurityViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    func setCellsInfo(_ cellsInfo: [CellInfo]) {
        controller?.cellsInfo = cellsInfo
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func addLastAccessCell(_ cell: CellInfo) {
        controller?.cellsInfo.append(cell)
    }
    
    func showBiometryMessage(localizedKey: String, biometryType: BiometryTypeEntity) {
        self.biometryViewHelper.showBiometryMessage(
            localizedKey: localizedKey,
            biometryType: biometryType
        )
    }
    
    func showBiometryAlert(localizedKey: String, biometryText: String) {
        self.biometryViewHelper.showBiometryAlert(
            localizedKey: localizedKey,
            biometryText: biometryText
        )
    }
}
