import UIKit
import UI
import CoreFoundationLib

protocol PrivateSubmenuPresenterProtocol: PrivateSideMenuFooterProtocol, Presenter {
    func backbuttonTouched()
    func selectSection(_ section: TableModelViewSection)
}

final class PrivateSubmenuViewController: BaseViewController<PrivateSubmenuPresenterProtocol>, TableDataSourceDelegate {
    
    override class var storyboardName: String {
        return "PrivateMenuStoryboard"
    }
    
    private var submenuOffersArray: [String] = []
    private var submenuBannersArray: [String] = []
    
    var sectionTitle: LocalizedStylableText? {
        didSet {
            if let text = sectionTitle {
                titleLabel.set(localizedStylableText: text.uppercased())
            } else {
                titleLabel.text = nil
            }
        }
    }
    var sectionSuperTitle: LocalizedStylableText? {
        didSet {
            if let text = sectionSuperTitle {
                self.superTitleLabel.set(localizedStylableText: text.uppercased())
            } else {
                self.superTitleLabel.text = nil
            }
        }
    }
    
    lazy var adapter: TableDataSource = {
        let dataSource = TableDataSource()
        dataSource.delegate = self
        
        return dataSource
    }()
    
    public var imageBannerViewModel: ImageBannerViewModel?
    public var offerViewModel: OfferPrivateMenuViewModel?
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var backButton: ResponsiveButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var superTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomOptionsBarContainer: UIView!
    @IBOutlet weak var bottomOptionsBarView: OptionsBarView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dashSeparatorView: UIView!
    @IBOutlet weak var helpUsButton: BannerPressFXView!
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .clear(tintColor: .clear)
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .sky30
        headerView.backgroundColor = .sky30
        separator.backgroundColor = .mediumSky
        bottomOptionsBarContainer.backgroundColor = .sky30
        bottomOptionsBarView.backgroundColor = .sky30
        titleLabel.textColor = .lisboaGrayNew
        titleLabel.font = .santanderTextBold(size: 17)
        self.superTitleLabel.setSantanderTextFont(type: .regular, size: 10.0, color: .sanGreyDark)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "MenuOfferTableViewCell", bundle: .module),
                           forCellReuseIdentifier: "MenuOfferTableViewCell")
        tableView.register(UINib(nibName: "MenuSimpleItemTableViewCell", bundle: .module),
                           forCellReuseIdentifier: "MenuSimpleItemTableViewCell")
        tableView.register(UINib(nibName: "MenuFeaturedItemTableViewCell", bundle: .module),
                           forCellReuseIdentifier: "MenuFeaturedItemTableViewCell")
        tableView.register(UINib(nibName: "BannerTableViewCell", bundle: .module),
                           forCellReuseIdentifier: "BannerTableViewCell")
        tableView.register(UINib(nibName: "MenuSectionTitleTableViewCell", bundle: .module),
                           forCellReuseIdentifier: "MenuSectionTitleTableViewCell")
        tableView.accessibilityIdentifier = "MyProductsSideMenuTable"
        backButton.setImage(Assets.image(named: "icnArrowLeftBlack"), for: .normal)
        tableView.contentInset = UIEdgeInsets(top: 23.0, left: 0, bottom: 23.0, right: 0)
        setupFooter()
        self.setAccessibilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func addSections(sections: [TableModelViewSection]) {
        adapter.addSections(sections)
        tableView.reloadData()
    }
    
    private func setupFooter() {
        separatorView.backgroundColor = .mediumSkyGray
        bottomOptionsBarView.backgroundColor = .sky30
        dashSeparatorView.drawShadow(offset: (x: 0, y: 0), opacity: 1, color: .coolGray, radius: 2.0)
        if let opinatorTitle = presenter?.opinatorTitle {
            helpUsButton.setTitle(opinatorTitle)
            helpUsButton.setIcon("icnHelpUs")
            helpUsButton.action = { [weak self] in
                self?.presenter?.didTapHelpUs()
            }
            helpUsButton.isHidden = false
        } else {
            helpUsButton.isHidden = true
        }
    }
    
    func setBottomOptions(_ options: [PrivateMenuOption]) {
        bottomOptionsBarView.setOptions(options)
    }
    
    func setNotificationBadgeVisible(_ visible: Bool, inCoachmark id: CoachmarkIdentifier?) {
        bottomOptionsBarView.setNotificationBadgeVisible(visible, inCoachmark: id)
    }
    
    func setAccessibilityIdentifiers() {
        self.helpUsButton.isAccessibilityElement = true
        self.helpUsButton.accessibilityIdentifier = AccessibilitySideMenu.btnHelpUsImprove
    }
        
    // MARK: - TableDataSourceDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: selectedIndexPath, animated: true)
        let section = adapter.sections[indexPath.section]
        presenter.selectSection(section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isAccessibilityElement = true
        if (cell as? MenuOfferTableViewCell) != nil {
            cell.accessibilityIdentifier = AccessibilitySideProduct.btnInterestOffert
        } else if (cell as? BannerTableViewCell) != nil {
            if cell.accessibilityIdentifier == nil {
                cell.accessibilityIdentifier = AccessibilitySideProduct.btnBanner
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        presenter.backbuttonTouched()
    }
}
