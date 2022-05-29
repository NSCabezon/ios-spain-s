//
//  DigitalProfileViewController.swift
//  PersonalArea
//
//  Created by alvola on 05/12/2019.
//

import UIKit
import CoreFoundationLib
import UI
import CoreDomain

struct DigitalProfileViewModel {
    let percentage: Double
    let category: DigitalProfileEnum
    let configuredItems: [DigitalProfileElemProtocol]
    let notConfiguredItems: [DigitalProfileElemProtocol]
    let username: String
    let userLastname: String
    let userImage: Data?
}

protocol DigitalProfileViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    var presenter: DigitalProfilePresenterProtocol { get }
    func showComingSoonToast()
    func configureView(model: DigitalProfileViewModel)
}

protocol DigitalProfileProtocol: AnyObject {
    func didSwipeCarrousel()
}

final class DigitalProfileViewController: UIViewController {
    @IBOutlet weak var header: DigitalProfileHeader?
    @IBOutlet weak var tableView: UITableView?
    let presenter: DigitalProfilePresenterProtocol
    private var controller: DigitalProfileTableController?
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    init(presenter: DigitalProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "DigitalProfileViewController", bundle: Bundle.module)
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
        presenter.viewWillAppear()
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureTableView()
        initializeController()
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_digitalProfile",
                type: .red,
                action: { [weak self] sender in
                    self?.showGeneralTooltip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(backButtonPressed)))
        builder.setRightActions(.menu(action: #selector(drawerPressed)))
        builder.build(on: self, with: self.presenter)
    }

    private func showGeneralTooltip(_ sender: UIView) {
        presenter.infoAction()
        DigitalProfileTooltip.showTooltip(in: self, from: sender)
    }
    
    @objc private func backButtonPressed() { presenter.backButtonAction() }
    @objc func searchButtonPressed() { presenter.searchAction() }
    @objc private func drawerPressed() { presenter.drawerAction() }

    private func configureTableView() {
        view.backgroundColor = UIColor.white
        tableView?.backgroundColor = UIColor.clear
        tableView?.separatorStyle = .none
    }
    
    private func initializeController() {
        self.controller = DigitalProfileTableController(tableView: self.tableView)
        self.controller?.delegate = self.presenter
    }
}

extension DigitalProfileViewController: DigitalProfileViewProtocol {
    
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    func showComingSoonToast() { Toast.show("Próximamente") }
    
    func configureView(model: DigitalProfileViewModel) {
        let headerModel = DigitalProfileModelWithUser(
            username: model.username,
            userLastname: model.userLastname,
            userImage: model.userImage,
            digitalProfile: model.category,
            percentage: model.percentage
        )
        self.header?.setInfo(headerModel)
        self.controller?.setInfo(configured: model.configuredItems, notConfigured: model.notConfiguredItems)
    }
}

extension DigitalProfileViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
