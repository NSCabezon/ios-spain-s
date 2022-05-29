//
//  PersonalAreaMainModuleViewController.swift
//  PersonalArea
//
//  Created by alvola on 06/03/2020.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain

protocol PersonalAreaMainModuleViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    var presenter: PersonalAreaMainModulePresenterProtocol { get }
    
    func setUserPref(_ userPref: UserPrefWrapper?)
    func setAvatarImage(data: Data?)
    func showComingSoonToast()
}

final class PersonalAreaMainModuleViewController: UIViewController {
    
    @IBOutlet weak var header: PersonalAreaUserNameHeader?
    @IBOutlet weak var tableView: UITableView?
    
    let presenter: PersonalAreaMainModulePresenterProtocol
    private let dependenciesResolver: DependenciesResolver

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
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }

    init(presenter: PersonalAreaMainModulePresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "PersonalAreaMainModuleViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        presenter.viewBecomeActive()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    private func commonInit() {
        configureTableView()
        configureHeader()
        initializeController()
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_personalArea")
        )
        builder.setLeftAction(.back(action: #selector(backDidPressed)))
        builder.setRightActions(.menu(action: #selector(drawerDidPressed)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func backDidPressed() { presenter.backButtonAction() }
    @objc func searchButtonPressed() { presenter.searchAction() }
    @objc private func drawerDidPressed() { presenter.drawerAction() }
    
    private func configureTableView() {
        view.backgroundColor = UIColor.white
        
        tableView?.backgroundColor = UIColor.clear
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 92
    }
    
    private func configureHeader() {
        header?.delegate = self
    }
    
    private func initializeController() {
        controller = PersonalAreaTableViewController(tableView: tableView)
    }
}

extension PersonalAreaMainModuleViewController: PersonalAreaMainModuleViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    func setUserPref(_ userPref: UserPrefWrapper?) {
        controller?.cellsInfo = PersonalAreaSection.main.cellsDictionaryWith(userPref) ?? []
        header?.setUsername(userPref?.username ?? "")
        tableView?.reloadData()
        tableView?.scrollToNearestSelectedRow(at: .none, animated: true)
    }
    
    func setAvatarImage(data: Data?) {
        if let data = data, let image = UIImage(data: data) {
            header?.setImage(image)
        } else {
            header?.setImage(nil)
        }
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension PersonalAreaMainModuleViewController: PersonalAreaUserNameHeaderDelegate {
    func cameraDidPressed() { presenter.cameraAction() }
    func userInfoDidPressed() { presenter.userInfoAction() }
}

extension PersonalAreaMainModuleViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}
