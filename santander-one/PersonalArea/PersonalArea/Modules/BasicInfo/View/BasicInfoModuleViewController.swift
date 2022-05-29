//
//  BasicInfoModuleViewController.swift
//  PersonalArea
//
//  Created by alvola on 14/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol BasicInfoViewProtocol: UIViewController, LoadingViewPresentationCapable {
    var presenter: BasicInfoPresenterProtocol? { get }
    
    func setUserPref(_ userPref: UserPrefWrapper?, dependencies: DependenciesResolver?)
    func setAvatarImage(data: Data?)
    func showComingSoonToast()
}

final class BasicInfoModuleViewController: UIViewController {
    @IBOutlet weak var header: UserDataHeaderView?
    @IBOutlet weak var tableView: UITableView?
    
    internal let presenter: BasicInfoPresenterProtocol?
    private var controller: PersonalAreaTableViewControllerProtocol?

    init(presenter: BasicInfoPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: "BasicInfoModuleViewController", bundle: Bundle.module)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
        self.commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        self.presenter?.viewBecomeActive()
    }
    
    private func commonInit() {
        self.configureTableView()
        self.initializeController()
        self.header?.delegate = self
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
               style: .sky,
               title: .title(key: "toolbar_title_personalArea")
           )
           builder.setLeftAction(.back(action: #selector(backDidPressed)))
           builder.setRightActions(.close(action: #selector(closeDidPressed)))
           builder.build(on: self, with: nil)
    }
    
    private func configureTableView() {
        self.view.backgroundColor = UIColor.mediumSkyGray
        self.tableView?.backgroundColor = UIColor.white
        self.tableView?.separatorStyle = .none
    }
    
    private func initializeController() {
        self.controller = PersonalAreaTableViewController(tableView: tableView)
        self.controller?.setDelegate(presenter as? (PersonalAreaTableViewControllerDelegate & PersonalAreaActionCellDelegate))
    }
    
    @objc private func backDidPressed() {
        self.presenter?.backDidPress()
    }
    
    @objc private func closeDidPressed() {
        self.presenter?.closeDidPress()
    }
}

extension BasicInfoModuleViewController: BasicInfoViewProtocol {
    func setUserPref(_ userPref: UserPrefWrapper?, dependencies: DependenciesResolver?) {
        self.controller?.cellsInfo = PersonalAreaSection.userData.cellsDictionaryWith(userPref, resolver: dependencies) ?? []
    }
    
    func setAvatarImage(data: Data?) {
        if let data = data {
            self.header?.setImage(UIImage(data: data))
        } else {
            self.header?.setImage(nil)
        }
    }
    
    func showComingSoonToast() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension BasicInfoModuleViewController: UserDataHeaderDelegate {
    func cameraDidPressed() {
        self.presenter?.cameraDidPress()
    }
}

extension BasicInfoModuleViewController {
    var associatedLoadingView: UIViewController { self }
}
