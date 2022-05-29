//
//  PGPersonalizationViewController.swift
//  Alamofire
//
//  Created by David Gálvez Alonso on 25/11/2019.
//

import UIKit
import CoreFoundationLib
import UI

enum PGPersonalizationSubview {
    case discreteModeView
    case financingChartsView
    case frequentOperationsView
    case productsView
    case themeSelectorView
}

protocol PGPersonalizationViewProtocol: UIViewController {
    var presenter: PGPersonalizationPresenterProtocol? { get }
    
    func setInfo(_ info: [PageInfo], title: LocalizedStylableText, bannedIndexes: [Int])
    func setCurrentSelectedPG(currentIndex: Int)
    func setCurrentPGElements(_ elements: [PGPersonalizationSubview])
    func offerViewIsHidden(_ isHidden: Bool)
    func setIsDiscretModeActivated(isActivated: Bool)
    func setIsChartModeActivated(isActivated: Bool)
    func setUserBudget(_ userBudget: Double?)
    func getOptionPagerSelected() -> Int
    func getDiscretModeIsOn() -> Bool
    func getChartModeIsOn() -> Bool
    func getThemeColor() -> Int?
    func showFeatureNotAvailable()
}

final class PGPersonalizationViewController: UIViewController {
    
    @IBOutlet weak var pagerView: GeneralViewCollectionView?
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var discreteModeView: DiscreteModeView!
    @IBOutlet weak var themeColorSelector: ThemeColorSelectorView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var saveChangesButton: WhiteLisboaButton!
    @IBOutlet weak var financingChartsView: FinancingChartsView!
    @IBOutlet weak var frequentOperationsView: FrequentOperationsView!
    @IBOutlet weak var productsView: ProductsView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var themeColorTrailingConstraint: NSLayoutConstraint!
    let presenter: PGPersonalizationPresenterProtocol?
    private var selectedPGSmartColorID: Int?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: PGPersonalizationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()        
        pagerView?.layoutSubviews()
        presenter?.viewWillAppear()
    }
    
    // MARK: - privateMethods
    
    private func commonInit() {
        configureDelegates()
        configurePagerView()
        configureButton()
        backgroundView.backgroundColor = .bg
        stackView.backgroundColor = .skyGray
        separator.backgroundColor = .mediumSkyGray
        self.themeColorSelector.alpha = 0.0
        self.themeColorTrailingConstraint.constant = Screen.isIphone4or5 ? 40.0 : 60.0
    }
    
    private func configureDelegates() {
        discreteModeView.setDelegate(self)
        financingChartsView.setDelegate(self)
        frequentOperationsView.setDelegate(self)
        productsView.setDelegate(self)
        pagerView?.generalViewCollectionViewDelegate = self
        themeColorSelector.themeSelectorDelegate = self
    }
    
    private func configurePagerView() {
        pagerView?.applyGradientBackground(colorStart: .white, colorFinish: .bg)
        pagerView?.personalAreaCollectionView.bounces = false
        
    }
    
    private func configureNavigationBar() {
        let style: NavigationBarBuilder.Style
        if #available(iOS 11.0, *) {
            style = .clear(tintColor: .santanderRed)
        } else {
            style = .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
        let builder = NavigationBarBuilder(
            style: style,
            title: .title(key: "toolbar_title_displayOptions")
        )
        builder.setLeftAction(.back(action: #selector(backDidPressed)))
        builder.setRightActions(.close(action: #selector(closeDidPressed)))
        builder.build(on: self, with: nil)
    }
    
    private func configureButton() {
        saveChangesButton.layer.cornerRadius = 20
        saveChangesButton.layer.borderWidth = 1
        saveChangesButton.layer.borderColor = UIColor.santanderRed.cgColor
        saveChangesButton.setTitle(localized("displayOptions_button_saveChanges"), for: .normal)
        saveChangesButton.accessibilityIdentifier = AccessibilityPGPersonalizationPersonalArea.saveChangesButton
        saveChangesButton.addSelectorAction(target: self, #selector(saveChangesButtonDidPressed(_:)))
    }
    
    @objc private func backDidPressed() { presenter?.backDidPressed() }
    @objc private func closeDidPressed() { presenter?.closeDidPressed() }
    
    @IBAction func saveChangesButtonDidPressed(_ sender: Any) {
        presenter?.saveChangesButtonDidPressed() }
}

extension PGPersonalizationViewController: PGPersonalizationViewProtocol {
    
    func setInfo(_ info: [PageInfo], title: LocalizedStylableText, bannedIndexes: [Int]) {
        pagerView?.setInfo(info)
        pagerView?.titlePage = title
        pagerView?.setBannedIndexes(bannedIndexes)
    }
    
    func setCurrentSelectedPG(currentIndex: Int) {
        pagerView?.setCurrentPage(currentIndex)
    }
    
    func setCurrentPGElements(_ elements: [PGPersonalizationSubview]) {
        self.discreteModeView.isHidden = !elements.contains(.discreteModeView)
        self.financingChartsView.isHidden = !elements.contains(.financingChartsView)
        self.frequentOperationsView.isHidden = !elements.contains(.frequentOperationsView)
        self.productsView.isHidden = !elements.contains(.productsView)
        if elements.contains(.themeSelectorView) {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                self?.themeColorSelector.alpha = 1.0
                }, completion: nil)
        }
    }
    
    func setIsDiscretModeActivated(isActivated: Bool) {
        discreteModeView.setSwitchIsOn(isActivated)
    }
    
    func setIsChartModeActivated(isActivated: Bool) {
        financingChartsView.setSwitchIsOn(isActivated)
    }
    
    func setUserBudget(_ userBudget: Double?) {
        financingChartsView.setUserBudget(userBudget)
    }
    
    func offerViewIsHidden(_ isHidden: Bool) {
        discreteModeView.offerViewIsHidden(isHidden)
    }
    
    func getOptionPagerSelected() -> Int {
        return pagerView?.selectedPageIndex ?? 0
    }
    
    func getDiscretModeIsOn() -> Bool {
        return discreteModeView.getSwitchIsOn()
    }
    
    func getChartModeIsOn() -> Bool {
        return financingChartsView.getSwitchIsOn()
    }
    
    func getThemeColor() -> Int? {
        return self.selectedPGSmartColorID ?? nil
    }
    
    func showFeatureNotAvailable() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension PGPersonalizationViewController: OfferViewDelegate {
    func offerViewDidPressed() { presenter?.offerViewDidPressed() }
}

extension PGPersonalizationViewController: FinancingChartsViewDelegate {
    func financingChartsViewDidPressed() { presenter?.financingChartsViewDidPressed() }
}

extension PGPersonalizationViewController: FrequentOperationsViewDelegate {
    func frequentOperationsViewDidPressed() { presenter?.frequentOperationsViewDidPressed() }
}

extension PGPersonalizationViewController: ProductsViewDelegate {
    func productsViewDidPressed() { presenter?.productsViewDidPressed() }
}

extension PGPersonalizationViewController: GeneralViewCollectionViewDelegate {
    func didSelectPageInfo(_ pageInfo: PageInfo) {
        if pageInfo.isEditable {
            switch pageInfo.smartColorMode {
            case .red:
                self.themeColorSelector.toggleButtonType(buttonType: .red, toActive: true)
                
            case .black:
                self.themeColorSelector.toggleButtonType(buttonType: .black, toActive: true)
            case .none:
                break
            }
        }
        self.presenter?.currentIndexDidChange(self.pagerView?.selectedPageIndex ?? 0)
    }
    
    func didBegingScrolling() {
        self.themeColorSelector.alpha = 0
    }
    
    func didEndScrolling() {
        self.presenter?.didSwipe()
    }
    
    func didEndScrollingSelectedItem() {}
    
}

extension PGPersonalizationViewController: ThemeColorSelectorViewDelegate {
    func didSelectButton(_ buttonType: ButtonType) {
        var selectedSlideInfo = self.pagerView?.selectedSlide()
        switch buttonType {
        case .red:
            selectedSlideInfo?.smartColorMode = .red
            selectedPGSmartColorID = 0
            self.pagerView?.personalAreaCollectionView.changeImageForSelectedPageView(imageNamed: "imgPgSmart", colorMode: .red)
        case .black:
            selectedSlideInfo?.smartColorMode = .black
            selectedPGSmartColorID = 1
            self.pagerView?.personalAreaCollectionView.changeImageForSelectedPageView(imageNamed: "imgYoungBlack", colorMode: .black)
        }
    }
}
