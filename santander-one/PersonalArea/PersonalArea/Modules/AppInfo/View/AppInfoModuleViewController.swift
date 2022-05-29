//
//  AppInfoModuleViewController.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import UI
import CoreFoundationLib

protocol AppInfoViewProtocol: UIViewController, LoadingViewPresentationCapable {
    var presenter: AppInfoPresenterProtocol? { get }
    
    func setAppName(_ name: String)
    func showUpdate(_ update: Bool)
    func setAppVersion(_ appVersion: String, soVersion: String)
    func setVersionHistory(_ versions: [VersionViewModel])
}

final class AppInfoModuleViewController: UIViewController {
    private let headerHeight: CGFloat = 95.0
    private lazy var header: AppInfoHeader = {
        let header = AppInfoHeader(frame: .zero)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        header.delegate = self
        header.showUpdate(false)
        return header
    }()
    
    @IBOutlet private weak var fakeNavbarView: UIView!
    @IBOutlet private weak var scrollableView: UIView!
    private var scrollableStackView = ScrollableStackView(frame: .zero)
    
    internal let presenter: AppInfoPresenterProtocol?
    
    init(presenter: AppInfoPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: "AppInfoModuleViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter?.didLoadView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

private extension AppInfoModuleViewController {
    func commonInit() {
        configureView()
        configureScrollView()
    }
    
    func configureNavigationBar() {
        let style: NavigationBarBuilder.Style
        if #available(iOS 11.0, *) {
            style = .clear(tintColor: .santanderRed)
        } else {
            style = .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
        let builder = NavigationBarBuilder(
            style: style,
            title: .title(key: "toolbar_title_appInformation")
        )
        builder.setLeftAction(.back(action: #selector(didPressBack)))
        builder.setRightActions(.close(action: #selector(didPressClose)))
        builder.build(on: self, with: nil)
    }
    
    func configureView() {
        fakeNavbarView.backgroundColor = .skyGray
        fakeNavbarView.layer.masksToBounds = false
        fakeNavbarView.layer.shadowColor = UIColor.black.cgColor
        fakeNavbarView.layer.shadowOpacity = 0.3
        fakeNavbarView.layer.shadowOffset = CGSize.zero
        fakeNavbarView.layer.shadowRadius = 0
    }
    
    func configureScrollView() {
        scrollableView.backgroundColor = .white
        scrollableStackView.setup(with: self.scrollableView)
        scrollableStackView.setBounce(enabled: false)
        scrollableStackView.setScrollDelegate(self)
        scrollableStackView.addArrangedSubview(header)
    }
    
    func addDottedSeparator() {
        let dotted = DottedLineView()
        dotted.backgroundColor = .white
        dotted.strokeColor = .mediumSkyGray
        dotted.translatesAutoresizingMaskIntoConstraints = false
        dotted.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.scrollableStackView.addArrangedSubview(dotted)
    }
    
    func addVersionDetailTitle() {
        let title = VersionDetailTitle()
        self.scrollableStackView.addArrangedSubview(title)
    }
    
    func addVersionDetailDescription(_ number: String, description: NSAttributedString) {
        let descriptionView = VersionDetailDescription()
        descriptionView.setNumber(number, description: description)
        self.scrollableStackView.addArrangedSubview(descriptionView)
    }
    
    @objc func didPressBack() {
        self.presenter?.didPressBack()
    }
    
    @objc func didPressClose() {
        self.presenter?.didPressClose()
    }
}

extension AppInfoModuleViewController: AppInfoViewProtocol {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func setAppName(_ name: String) {
        header.setAppName(name)
    }
    
    func showUpdate(_ update: Bool) {
        header.showUpdate(update)
    }
    
    func setAppVersion(_ appVersion: String, soVersion: String) {
        let version = VersionView(frame: .zero)
        version.setName(localized("appInformation_label_appVersion"), version: appVersion)
        version.setAccesibilityIdentifiers(AccesibilityConfigurationPersonalArea.appLabelVersion, AccesibilityConfigurationPersonalArea.appNumberVersion)
        self.scrollableStackView.addArrangedSubview(version)
        
        addDottedSeparator()
        
        let versionOS = VersionView(frame: .zero)
        versionOS.setName(localized("appInformation_label_osVersion"), version: soVersion)
        versionOS.setAccesibilityIdentifiers(AccesibilityConfigurationPersonalArea.appOsNumberVersion, AccesibilityConfigurationPersonalArea.appOsLabelVersion)
        self.scrollableStackView.addArrangedSubview(versionOS)
    }
    
    func setVersionHistory(_ versions: [VersionViewModel]) {
        addVersionDetailTitle()
        
        versions.enumerated().forEach {
            addVersionDetailDescription($0.element.number, description: $0.element.description)
            if $0.offset < versions.count {
                addDottedSeparator()
            }
        }
    }
}

extension AppInfoModuleViewController: AppInfoHeaderDelegate {
    func updateDidPress() {
        presenter?.didPressUpdate()
    }
}

extension AppInfoModuleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        fakeNavbarView.layer.shadowRadius = scrollView.contentOffset.y > headerHeight ? 2.0 : 0.0
    }
}
