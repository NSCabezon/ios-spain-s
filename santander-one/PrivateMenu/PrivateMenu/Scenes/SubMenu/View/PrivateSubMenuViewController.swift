import UIKit
import OpenCombine
import UI
import CoreDomain
import CoreFoundationLib

final class PrivateSubMenuViewController: UIViewController {
    private enum Constants {
        static let viewControllerNib = "PrivateSubMenuViewController"
        static let componentDefaultRadio: CGFloat = 2.0
        static let defaultOpacity: Float = 1.0
        static let titleLabelFontSize: CGFloat = 17.0
        static let superTitleLabelFontSize: CGFloat = 10.0
        static let tableTopInset: CGFloat = -16.0
        static let tableBottomInset: CGFloat = 23.0
        static let containerTopGap = 20.0
        static let containerInitialHeight = 100.0
    }
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var backButton: ResponsiveStateButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var superTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var bottomOptionsBarContainer: UIView!
    @IBOutlet private weak var bottomOptionsBarView: OptionsBarView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var dashSeparatorView: UIView!
    @IBOutlet private weak var helpUsButton: BannerPressFXView!
    private let viewModel: PrivateSubMenuViewModel
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: PrivateSubMenuDependenciesResolver
    private var menuItemsSubject = PassthroughSubject<[CollectionSection<SubMenuItem>], Never>()
    private var footerContainerView = SubmenuFooterView()
    private var initalFrame: CGRect = .zero
    init(dependencies: PrivateSubMenuDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: Constants.viewControllerNib, bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupFooter()
        bindViews()
        bindMenuOptions()
        bindFooterBanners()
        viewModel.viewDidLoad()
    }
}

private extension PrivateSubMenuViewController {
    func setupView() {
        self.initalFrame = self.footerContainerView.frame
        self.footerContainerView.frame.size.height = Constants.containerInitialHeight
        tableView.tableFooterView = self.footerContainerView
        self.footerContainerView.isHidden = true
        view.backgroundColor = .skyGray
        headerView.backgroundColor = .skyGray
        separator.backgroundColor = .mediumSkyGray
        bottomOptionsBarContainer.backgroundColor = .skyGray
        bottomOptionsBarView.backgroundColor = .skyGray
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .bold, size: Constants.titleLabelFontSize)
        superTitleLabel.textColor = .sanGreyDark
        superTitleLabel.font = .santander(family: .text, type: .regular, size: Constants.superTitleLabelFontSize)
        backButton.setImage(Assets.image(named: "icnArrowLeftBlack"), for: .normal)
        setAccessibilityIdentifiers()
        setupTableView()
        registerCell()
        menuItemsSubject
          .map { $0 }
          .bind(subscriber: tableView.sectionsSubscriber(cellIdentifier: "MenuItemTableViewCell",
                                                         cellType: MenuItemTableViewCell.self,
                                                         sectionIdentifier: "SubMenuSectionTableViewHeader",
                                                         cellConfig: { cell, _, model in
                cell.configureWithModel(model)
            }))
            .store(in: &anySubscriptions)
    }
    
    func setupFooter() {
        separatorView.backgroundColor = .mediumSkyGray
        bottomOptionsBarView.backgroundColor = .skyGray
        dashSeparatorView.drawShadow(offset: (x: .zero, y: .zero),
                                     opacity: Constants.defaultOpacity,
                                     color: .coolGray,
                                     radius: Constants.componentDefaultRadio)
        bottomOptionsBarView.backgroundColor = .skyGray
        helpUsButton.setIcon("icnHelpUs")
        helpUsButton.setTitleWithKey("menu_link_improve")
        helpUsButton.pressFXColor = .lightSky
        helpUsButton.isHidden = false
        helpUsButton.action = { [weak self] in
            self?.viewModel.didSelectHelpUs()
        }
    }
    
    func bindViews() {
        bindHeaderData()
        bindFooterOptions()
        bindYourManager()
    }
    
    func bindYourManager() {
        viewModel.state
            .case(PrivateSubMenuState.yourManager)
            .sink { _ in
            } receiveValue: { [unowned self] manager in
                guard let imageData = manager.thumbnailData,
                        let image = UIImage(data: imageData) else { return }
                self.bottomOptionsBarView.personalManagerImageSubject.send(image)
            }.store(in: &anySubscriptions)
    }
    
    func bindHeaderData() {
        viewModel.state
            .case (PrivateSubMenuState.headerData)
            .sink { [unowned self] headerData in
                self.titleLabel.text = headerData.title
                self.superTitleLabel.text = headerData.superTitle
                setAccessibilityTitle(headerData)
            }
            .store(in: &anySubscriptions)
    }
    
    func bindFooterOptions() {
        viewModel.state
            .case (PrivateSubMenuState.footerOptions)
            .map { values in
                values.map { PrivateMenuFooterOption(option: $0) }
            }
            .subscribe(bottomOptionsBarView.optionsSubject)
            .store(in: &anySubscriptions)
        viewModel.state
            .case (PrivateSubMenuState.personalManagerBadge)
            .subscribe(bottomOptionsBarView.personalManagerBadgeSubject)
            .store(in: &anySubscriptions)
        bottomOptionsBarView
            .didSelectOptionSubject
            .sink { [unowned self] value in
                switch value {
                case .atm:
                    self.viewModel.didSelectATM()
                case .helpCenter:
                    self.viewModel.didSelectHelpCenter()
                case .myManager:
                    self.viewModel.didSelectMyManager()
                case .security:
                    self.viewModel.didSelectSecurity()
                }
            }.store(in: &anySubscriptions)
    }
    
    func bindMenuOptions() {
        viewModel.state
            .case (PrivateSubMenuState.menuOptions)
            .map { sections in
                return sections.map { section in
                    CollectionSection(header: section.titleKey, items: section.items)
                }
            }
            .sink { [unowned self] menuSections  in
                menuItemsSubject.send(menuSections)
            }
            .store(in: &anySubscriptions)
        // MARK: - TableView Events
        self.tableView.selectedCellSubject()?.sink(receiveValue: { [weak self] item in
            guard let self = self,
                  let selectedItem = item as? PrivateSubMenuOptionRepresentable else { return }
            self.viewModel.didSelectOption(selectedItem.action)
        })
            .store(in: &anySubscriptions)
    }
    
    func bindFooterBanners() {
        viewModel.state
            .case (PrivateSubMenuState.footerBanner)
            .sink { [unowned self] banners in
                self.footerContainerView.isHidden = false
                self.createBannersWithOffer(banners)
            }
            .store(in: &anySubscriptions)
    }
    
    @IBAction func backButtonTapped(_ sender: ResponsiveStateButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: Constants.tableTopInset,
                                              left: .zero,
                                              bottom: Constants.tableBottomInset,
                                              right: .zero)
    }
    
    func registerCell() {
        let menuFeaturedCell = UINib(nibName: "MenuItemTableViewCell", bundle: .module)
        self.tableView.register(menuFeaturedCell, forCellReuseIdentifier: "MenuItemTableViewCell")
        self.tableView.register(SubMenuSectionTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "SubMenuSectionTableViewHeader")
    }
    
    func setAccessibilityTitle(_ option: PrivateSubMenuHeaderData) {
        titleLabel.accessibilityIdentifier = option.title
        superTitleLabel.accessibilityIdentifier = option.superTitle
    }
    
    func setAccessibilityIdentifiers() {
        helpUsButton.accessibilityIdentifier = AccessibilitySideMenu.btnHelpUsImprove
        self.helpUsButton.isAccessibilityElement = true
        backButton.accessibilityIdentifier = AccessibilitySideMenu.icnBack
    }
}

extension PrivateSubMenuViewController {
    // TableFooterView hack to correctly resize on footer change
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let footerView = self.tableView.tableFooterView else {
                return
        }
        let width = self.tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(
            CGSize(width: width,
                   height: UIView.layoutFittingCompressedSize.height))
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tableView.tableFooterView = footerView
        }
    }
}

private extension PrivateSubMenuViewController {
    func createBannersWithOffer(_ banners: [OfferBanner?]) {
        banners.forEach { [weak self] banner in
            let bannerView = bannerWithModel(banner)
            bannerView.setModel(banner)
            bannerView.tapSubject.sink { offer in
                self?.viewModel.didSelectOffer(offer)
            }.store(in: &anySubscriptions)
        }
        updateTableFooterHeigh()
    }
    
    func bannerWithModel(_ model: OfferBanner?) -> BannerView {
        let bannerView = BannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.accessibilityIdentifier = model?.privateSubMenuOptions.accessibilityId
        self.footerContainerView.setView(bannerView)
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: self.footerContainerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: self.footerContainerView.trailingAnchor)
        ])
        return bannerView
    }
    
    func updateTableFooterHeigh() {
        guard footerContainerView.subviews.isNotEmpty else { return }
        let allBannerHeights = footerContainerView.subviews[0].subviews
            .flatMap { $0.frame.size.height}
            .reduce(0, +)
        let bottomSpace = allBannerHeights + Constants.containerTopGap
        self.tableView.contentSize.height += bottomSpace
        self.footerContainerView.frame.size.height += bottomSpace
    }
}

