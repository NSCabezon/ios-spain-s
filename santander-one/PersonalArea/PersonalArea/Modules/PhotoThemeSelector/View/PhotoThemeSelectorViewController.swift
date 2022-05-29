import UIKit
import CoreFoundationLib
import UI

protocol PhotoThemeSelectorViewProtocol: UIViewController, LoadingViewPresentationCapable {
    var presenter: PhotoThemeSelectorPresenterProtocol? { get }
    func setInfo(_ info: [PageInfo], title: LocalizedStylableText?, bannedIndexes: [Int])
    func setCurrentSelectedTheme(currentIndex: Int)
    func getOptionPagerSelected() -> Int?
    func showError()
}

protocol PhotoThemeViewControllerProtocol: AnyObject {
    func didSwipe()
}

final class PhotoThemeSelectorViewController: UIViewController {
    @IBOutlet weak var generalViewCollectionView: GeneralViewCollectionView!
    @IBOutlet weak var saveChangesButton: WhiteLisboaButton!
    @IBOutlet weak var separatorView: UIView!
    let presenter: PhotoThemeSelectorPresenterProtocol?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: PhotoThemeSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        presenter?.viewDidLoad()
        generalViewCollectionView.photoThemeDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradientBackground(colorStart: .white, colorFinish: .bg)
        generalViewCollectionView?.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.configureNavigationBar()
        } else {
            self.configureNavigationBarIos10()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // MARK: - privateMethods
    
    private func commonInit() {
        configureDelegates()
        configurePagerView()
        configureGeneralViewCollectionView()
        configureButton()
        separatorView.backgroundColor = .mediumSkyGray
    }
    
    private func configureDelegates() {
        
    }
    
    private func configurePagerView() {
        generalViewCollectionView?.applyGradientBackground(colorStart: .white, colorFinish: .bg)
    }
    
    private func configureGeneralViewCollectionView() {
        generalViewCollectionView?.applyGradientBackground(colorStart: .white, colorFinish: .bg)
    }
    
    private func configureNavigationBarIos10() {
        let builder = NavigationBarBuilder(
            style: .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed),
            title: .title(key: "toolbar_title_sujetPhoto")
        )
        builder.setLeftAction(.back(action: #selector(backDidPress)))
        builder.setRightActions(.close(action: #selector(closeDidPress)))
        builder.build(on: self, with: nil)
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
            title: .title(key: "toolbar_title_sujetPhoto")
        )
        builder.setLeftAction(.back(action: #selector(backDidPress)))
        builder.setRightActions(.close(action: #selector(closeDidPress)))
        builder.build(on: self, with: nil)
    }
    
    private func configureButton() {
        saveChangesButton.setTitle(localized("generic_button_change"), for: .normal)
        saveChangesButton.layer.cornerRadius = saveChangesButton.frame.height/2
        saveChangesButton?.addSelectorAction(target: self, #selector(saveChangesButtonDidPressed))
        saveChangesButton.accessibilityIdentifier = AccessibilityPhotoThemePersonalizationPersonalArea.saveThemeChangesButton
    }
    
    @objc private func backDidPress() {
        presenter?.backDidPress()
        
    }
    @objc private func closeDidPress() {
        presenter?.closeDidPress()
        
    }
    @objc private func saveChangesButtonDidPressed(_ sender: Any) {
        presenter?.saveChangesButtonDidPress()
    }
}

extension PhotoThemeSelectorViewController: PhotoThemeSelectorViewProtocol {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func showError() {
        let dialog = LisboaDialog(items: [
            LisboaDialogItem.margin(27),
            .styledText(LisboaDialogTextItem(text: localized("onboarding_alert_title_errorImages"),
                                             font: .santander(family: .headline, type: .regular, size: 22),
                                             color: .black,
                                             alignament: .center,
                                             margins: (24, 24))),
            .margin(17),
            .styledText(LisboaDialogTextItem(text: localized("personalArea_alert_text_errorImages"),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: .lisboaGray,
                                             alignament: .center,
                                             margins: (24, 24))),
            .margin(34),
            .verticalAction(VerticalLisboaDialogAction(title: localized("generic_button_understand"), type: .red, margins: (18, 18), action: { [weak self] in
                self?.presenter?.didAcceptError()
            })),
            .margin(30)
            
        ], closeButtonAvailable: false)
        dialog.showIn(self)
    }
    
    func setInfo(_ info: [PageInfo], title: LocalizedStylableText?, bannedIndexes: [Int]) {
        guard let labels = info.first else {
            return
        }
        generalViewCollectionView?.setLabels(labels)
        generalViewCollectionView?.setInfo(info)
        generalViewCollectionView?.setBannedIndexes(bannedIndexes)
    }
    
    func setCurrentSelectedTheme(currentIndex: Int) {
        generalViewCollectionView?.setCurrentPage(currentIndex)
    }
    
    func getOptionPagerSelected() -> Int? {
        return generalViewCollectionView?.selectedSlide()?.id
    }
}

extension PhotoThemeSelectorViewController: GeneralPagerViewDelegate {
    func currentIndexDidChange(_ index: Int) {
        self.presenter?.currentIndexDidChange(index)
    }
}

extension PhotoThemeSelectorViewController: PhotoThemeViewControllerProtocol {
    func didSwipe() {
        presenter?.didSwipe()
    }
}
