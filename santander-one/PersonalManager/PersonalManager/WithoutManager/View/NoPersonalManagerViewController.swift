//
//  NoPersonalManagerViewController.swift
//  PersonalManager
//
//  Created by alvola on 03/02/2020.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain

protocol NoPersonalManagerViewProtocol: class, NavigationBarWithSearchProtocol {
}

final class NoPersonalManagerViewController: UIViewController {
    
    @IBOutlet weak var fakeTopView: UIView?
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var headerImageView: UIImageView?
    @IBOutlet weak var headerTitleLabel: UILabel?
    @IBOutlet weak var headerSubtitleLabel: UILabel?
    @IBOutlet weak var topSeparationView: UIView?
    @IBOutlet weak var requirementsTitleLabel: StackedLabelView?
    @IBOutlet var requirementsLabelList: [RequirementView]?
    @IBOutlet weak var advantagesTitleLabel: StackedLabelView?
    @IBOutlet var advantageViewsList: [AdvantageView]?
    @IBOutlet weak var bottomSeparationView: UIView?
    @IBOutlet weak var requestButton: RedLisboaButton?
    
    public var isSearchEnabled: Bool = false {
        didSet {
            configureNavigationBar()
        }
    }
    
    private let presenter: NoPersonalManagerPresenterProtocol

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: NoPersonalManagerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - privateMethods
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .clear(tintColor: .white),
            title: .title(key: "toolbar_title_manager")
        )
        builder.setRightActions(
            .image(image: "iconMenuWhite", action: #selector(drawerPressed))
        )
        builder.setLeftAction(
            .back(action: #selector(backButtonPressed))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func backButtonPressed() { presenter.backButtonAction() }
    @objc public func searchButtonPressed() { presenter.searchAction() }
    @objc private func drawerPressed() { presenter.drawerAction() }
    @objc private func requestManagerDidPressed() { presenter.requestManagerAction() }
    
    private func commonInit() {
        configureView()
        configureHeader()
        configureRequirements()
        configureAdvantages()
        configureButton()
        setAccesibilityIds()
    }
    
    private func configureView() {
        fakeTopView?.backgroundColor = UIColor.blueAnthracita
        topSeparationView?.backgroundColor = UIColor.mediumSkyGray
        bottomSeparationView?.backgroundColor = UIColor.mediumSkyGray
    }
    
    private func configureHeader() {
        headerView?.backgroundColor = UIColor.blueAnthracita
        headerTitleLabel?.font = UIFont.santander(size: 20.0)
        headerTitleLabel?.textColor = .white
        headerTitleLabel?.set(localizedStylableText: localized("manager_title_withoutMenager"))
        headerSubtitleLabel?.font = UIFont.santander(size: 14.0)
        headerSubtitleLabel?.textColor = .white
        headerSubtitleLabel?.set(localizedStylableText: localized("manager_text_ownManager"))
        self.configureHeaderImageView()
    }
    
    private func configureHeaderImageView() {
        self.headerImageView?.contentMode = .top
        self.headerImageView?.clipsToBounds = true
        let image = Assets.image(named: "myManagerImgPhoneComplete")
        self.headerImageView?.image = image?.resizeTopAlignedToFill(newWidth: self.headerImageView?.frame.width ?? 0)
    }
    
    private func configureRequirements() {
        requirementsTitleLabel?.setText(localized("manager_subtitle_keeptoRequirement"), fontSize: 20.0)
        let titles = ["manager_text_productHigherValue", "manager_text_expensestHigherValue", "manager_text_investimentHigherValue"]
        requirementsLabelList?.enumerated().forEach({ $0.element.setTitle(localized(titles[$0.offset])) })
    }
    
    private func configureAdvantages() {
        advantagesTitleLabel?.setText(localized("manager_subtitle_enjoyAdvantage"), fontSize: 16.0)
        let advantages = [("icnClock", "manager_label_service24WithoutManager", "manager_text_allWeek"),
                          ("icnPencil", "manager_label_operativeWithoutManager", "manager_text_contractKey"),
                          ("icnDevice", "manager_label_comfortWithoutManager", "manager_text_contractComfort"),
                          ("icnCoins", "manager_label_freeServiceWithoutManager", "")]
        
        advantageViewsList?.enumerated().forEach({ $0.element.setTitle(localized(advantages[$0.offset].1),
                                                                       subtitle: localized(advantages[$0.offset].2),
                                                                       icon: localized(advantages[$0.offset].0)) })
    }
    
    private func configureButton() {
        requestButton?.setTitle(localized("manager_button_emptyView"), for: .normal)
        requestButton?.addSelectorAction(target: self, #selector(requestManagerDidPressed))
    }
    
    private func setAccesibilityIds() {
        requestButton?.accessibilityIdentifier = "btnRequestPersonalManager"
        headerView?.accessibilityIdentifier = "headerWithoutPersonalManager"
        headerImageView?.accessibilityIdentifier = "imgPhoneManager"
    }
    
}

extension NoPersonalManagerViewController: NoPersonalManagerViewProtocol {
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
}

extension NoPersonalManagerViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension NoPersonalManagerViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return nil
    }
}
