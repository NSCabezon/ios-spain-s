//
//  ConfigurationModuleViewController.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol ConfigurationViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    var presenter: ConfigurationPresenterProtocol { get }
    func setUserPref(_ userPref: UserPrefWrapper?, dependenciesResolver: DependenciesResolver?)
    func showComingSoonToast()
}

final class ConfigurationModuleViewController: UIViewController {
    @IBOutlet private weak var header: PersonalAreaInfoHeader?
    @IBOutlet private weak var tableView: UITableView?
    
    let presenter: ConfigurationPresenterProtocol
    
    private var controller: PersonalAreaTableViewControllerProtocol? {
        didSet {
            self.controller?.setDelegate(presenter as? (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate))
        }
    }
    
    public var isSearchEnabled: Bool = false {
        didSet {
            self.configureNavigationBar()
        }
    }
    
    init(presenter: ConfigurationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ConfigurationModuleViewController", bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.becomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        self.presenter.viewBecomeActive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: self)
    }
    
    @objc private func becomeActive() { self.presenter.viewBecomeActive() }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        self.header?.setImage(
            PersonalAreaSection.configuration.image(),
                         description: PersonalAreaSection.configuration.desc()
        )
        self.configureTableView()
        self.initializeController()
    }
    
    private func configureTableView() {
        self.view.backgroundColor = UIColor.white
        self.tableView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = .none
    }
    
    private func initializeController() {
        self.controller = PersonalAreaTableViewController(tableView: tableView)
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
               style: .sky,
               title: .title(key: PersonalAreaSection.configuration.title())
           )
        builder.setLeftAction(.back(action: #selector(self.backButtonPressed)))
        builder.setRightActions(.menu(action: #selector(self.drawerPressed)))
           builder.build(on: self, with: self.presenter)
    }
    
    @objc private func backButtonPressed() { self.presenter.backButtonAction() }
    @objc func searchButtonPressed() { self.presenter.searchAction() }
    @objc private func drawerPressed() { self.presenter.drawerAction() }
}

extension ConfigurationModuleViewController: ConfigurationViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { self.isSearchEnabled = enabled }
    
    func setUserPref(_ userPref: UserPrefWrapper?, dependenciesResolver: DependenciesResolver?) {
        self.controller?.cellsInfo = PersonalAreaSection.configuration.cellsDictionaryWith(userPref, resolver: dependenciesResolver) ?? []
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}
