//
//  OtherOperativesViewController.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 30/01/2020.
//

import UIKit
import CoreFoundationLib
import UI

protocol OtherOperativesViewProtocol: AnyObject {
    func addActions(_ actions: [AllOperativesViewModel], sectionTitle: String?, usingStyle style: ActionButtonStyle?)
    func configureSmartView(mode: PGColorMode)
    func configureClassicView()
    func endEditing()
    func showEmptyView(show: Bool, withSearchTerm term: String, showActionsView: Bool)
    func removeAllActions()
    func setSearchResultModel(_ viewModel: OtherOperativesSearchViewModel)
    func setTotalResults(_ results: Int)
    func setOperativesResults(_ results: Int)
    func hideTotalResults(_ hide: Bool)
    func hideOperativeResults(_ hide: Bool)
    func hideSearchViews(_ hide: Bool)
}

final class OtherOperativesViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var textFieldShadowView: UIView!
    @IBOutlet weak var textField: SearchFieldView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topTitleConstraint: NSLayoutConstraint!
    
    private let needHelpTitleHeight: CGFloat = 46.0
    
    private var shouldShowSmartStyle: Bool = false
    var presenter: OtherOperativesPresenterProtocol

    // MARK: Actions container
    private weak var actionsContainer: UIView?
    
    private lazy var actionsStackView: ActionButtonsStackView<AllOperativesViewModel> = {
        let stackView = ActionButtonsStackView<AllOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 14
        return stackView
    }()
    
    // MARK: Empty view container
    
    private weak var _emptyViewContainer: UIView?
    
    private lazy var classicEmptyView: SingleEmptyView = {
        let view = SingleEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.titleFont(.santander(family: .headline, size: 18.0))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        emptyViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: 211.0)
        emptyViewHeightConstraint?.isActive = true
        return view
    }()
    
    private lazy var smartEmptyView: SingleEmptyView = {
        let view = SingleEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.imageIsHidden(true)
        view.titleFont(.santander(family: .headline, size: 18.0),
                                 color: .white)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.layer.cornerRadius = 5.0
        emptyViewHeightConstraint = view.heightAnchor.constraint(equalToConstant: 230.0)
        emptyViewHeightConstraint?.isActive = true
        return view
    }()
    
    private var emptyView: SingleEmptyView {
        return shouldShowSmartStyle ? smartEmptyView: classicEmptyView
    }
    
    private var emptyViewContainer: UIView {
        get {
            return _emptyViewContainer ?? emptyView
        }
        set {
            _emptyViewContainer = newValue
        }
    }
    
    private var emptyViewHeightConstraint: NSLayoutConstraint?
    
    // MAR: - Search Results Views
    
    private lazy var operativesTitle: GlobalSearchHeaderSectionView = {
        let title = localized("operativeSearch_title_operational",
                              [StringPlaceholder(.number, String(0))])
        let header = GlobalSearchHeaderSectionView(headerTitle: title)
        header.heightAnchor.constraint(equalToConstant: 51.0).isActive = true
        header.titleTopSpace = 15.0
        header.backgroundColor = .clear
        return header
    }()
    
    private lazy var resultsView: GlobalSearchHeaderResults = {
        let view = GlobalSearchHeaderResults()
        view.accessibilityIdentifier = "OperativesViewHeaderResultsViewContainer"
        view.withoutSegmented = true
        view.hideTopSeparator(true)
        view.globalSearchHeaderResultsCollapsedHeight = 43.0
        view.titleTopDistance = 13.0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        return view
    }()
    
    private lazy var searchedFAQsContainer: NeedHelpForView = {
        let view = NeedHelpForView(topSpace: needHelpTitleHeight)
        view.addSubview(searchedFAQsView)
        searchedFAQsView.delegate = self
        view.hideSeparator(true)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        view.translatesAutoresizingMaskIntoConstraints = false
        searchedFAQsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchedFAQsView.topAnchor.constraint(equalTo: view.topAnchor,
                                              constant: needHelpTitleHeight).isActive = true
        searchedFAQsView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: searchedFAQsView.bottomAnchor).isActive = true
        view.accessibilityIdentifier = "OperativesViewSearchFAQsViewContainer"
        return view
    }()
    
    private lazy var searchedFAQsView: TripFaqsView = {
        let view = TripFaqsView(style: .globalSearchStyle)
        view.delegate = self
        return view
    }()
    
    private lazy var needHelpForSearchFaqsView: GlobalSearchFaqsView = {
        let view = GlobalSearchFaqsView()
        view.accessibilityIdentifier = "OperativesViewNeedHelpForSearchFAQsViewContainer"
        view.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        return view
    }()
    
    private lazy var homeTipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 288).isActive = true
        view.setStyle(HelpCenterTipsViewStyle.homeTipsStyle())
        view.setTitleAccessibilityIdentifier("search_title_tips")
        view.accessibilityIdentifier = "OperativesViewHomeTipsViewContainer"
        return view
    }()
    
    private lazy var actionsView: GlobalSearchActionView = {
        let view = GlobalSearchActionView()
        view.accessibilityIdentifier = "GlobalSearchViewSearchActionsViewContainer"
        view.delegate = self
        return view
    }()
    
    // MARK: Lifecycle
    
    init(nibName: String?, bundle: Bundle?, presenter: OtherOperativesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.viewDidLoad()
        self.setAccessibility()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        textField.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        textField.endEditing(true)
        self.presenter.finishAndDismissView()
    }
    
    // MARK: - Orientation. Only using shouldAutorotate because of the UINavigationController extension in UI
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldShadowView.layer.shadowPath = UIBezierPath(rect: textFieldShadowView.bounds).cgPath
    }
}

private extension OtherOperativesViewController {
    func setAccessibility() {
        textField.accessibilityLabel = "\((textField.textField.fieldValue ?? "") + localized(AccessibilityGlobalPosition.pgSearchInputTextWhatNeed))"
        closeButton.accessibilityLabel = localized("modal_text_cta")
    }
    
    func setupUI() {
        stackView.addArrangedSubview(resultsView)
        resultsView.isHidden = true
        stackView.addArrangedSubview(operativesTitle)
        operativesTitle.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        operativesTitle.isHidden = true
        let actionsContainer = actionsStackView.embedIntoView(bottomMargin: 18, leftMargin: 15, rightMargin: 15)
        stackView.addArrangedSubview(actionsContainer)
        self.actionsContainer = actionsContainer
        stackView.backgroundColor = .clear
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        actionsContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        topTitleLabel.font = UIFont.santander(family: .headline, type: .bold, size: 16.0)
        topTitleLabel.text = localized("operate_label_operate")
        topTitleLabel.backgroundColor = .clear
        closeButton.backgroundColor = .clear
        configureTextField()
        if #available(iOS 11.0, *) {} else {
            topTitleConstraint.constant = 20
        }
        configureSearchViews()
    }
    
    func configureSearchViews() {
        stackView.addArrangedSubview(actionsView)
        actionsView.isHidden = true
        stackView.addArrangedSubview(searchedFAQsContainer)
        searchedFAQsContainer.isHidden = true
        stackView.addArrangedSubview(needHelpForSearchFaqsView)
        needHelpForSearchFaqsView.isHidden = true
        stackView.addArrangedSubview(homeTipsView)
        homeTipsView.isHidden = true
    }
    
    func configureTextField(smartMode: Bool = false) {
        var textFieldStyle: LisboaTextFieldStyle = textField.defaultSearchTextFieldStyle
        textFieldStyle.containerViewBackgroundColor = smartMode ? UIColor.white.withAlphaComponent(0.2) : UIColor.whitesmokes
        textFieldStyle.containerViewBorderWidth = 1.0
        textFieldStyle.containerViewBorderColor = (smartMode ? UIColor.clear : UIColor.lightSky).cgColor
        textFieldStyle.fieldBackgroundColor = smartMode ? UIColor.clear : UIColor.whitesmokes
        textFieldStyle.extraInfoViewBackgroundColor = smartMode ? UIColor.clear : UIColor.whitesmokes
        textFieldStyle.verticalSeparatorBackgroundColor = smartMode ? UIColor.white : UIColor.darkTurqLight
        textFieldStyle.extraInfoHorizontalSeparatorBackgroundColor = smartMode ? UIColor.white : UIColor.atmsShadowGray
        textFieldStyle.titleLabelTextColor = smartMode ? UIColor.white : UIColor.mediumSanGray
        textFieldStyle.fieldTintColor = smartMode ? UIColor.white : UIColor.darkTurqLight
        textFieldStyle.fieldTextColor = smartMode ? UIColor.white : UIColor.lisboaGray
        
        textField.configure(with: nil,
                            title: localized("globalSearch_inputText_whatNeed"),
                            style: textFieldStyle,
                            extraInfo: (Assets.image(named: smartMode ? "icnSearchWhite" : "icnSearch"), action: nil),
                            disabledActions: TextFieldActions.usuallyDisabledActions,
                            isNeededFloatingTitle: false)
        textField.mode = smartMode ? .white : .general
        textField.textFieldAction = { [weak self] text in
            self?.textFieldDidChange(text: text)
        }
        textField.clearIconAction = { [weak self] in
            self?.endEditing()
            self?.textFieldDidChange(text: nil)
        }
        textFieldShadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        textFieldShadowView.layer.shadowOpacity = 0
        textFieldShadowView.layer.shadowRadius = 0.8
        textFieldShadowView.layer.shadowOffset = CGSize.zero
        textFieldShadowView.layer.shadowPath = UIBezierPath(rect: textFieldShadowView.bounds).cgPath
    }
    
    func textFieldDidChange(text: String?) {
        presenter.updateActions(withText: text)
    }
}

extension OtherOperativesViewController: OtherOperativesViewProtocol {
    func addActions(_ actions: [AllOperativesViewModel], sectionTitle: String?, usingStyle style: ActionButtonStyle?) {
        self.actionsContainer?.isHidden = false
        self.emptyViewContainer.isHidden = true
        let sectionTitle: String? = sectionTitle.map(localized)
        self.actionsStackView.addActions(actions,
                                         sectionTitle: sectionTitle,
                                         usingStyle: style,
                                         delegate: nil)
    }
    
    func removeAllActions() {
        self.actionsStackView.removeAllArrangedSubviews()
    }
    
    func showEmptyView(show: Bool, withSearchTerm term: String, showActionsView: Bool) {
        self.emptyView.updateTitle(localized("globalSearch_title_empty", [StringPlaceholder(.value, term)]))
        self.emptyViewContainer.isHidden = !show
        self.actionsContainer?.isHidden = !showActionsView
    }
    
    @objc func endEditing() {
        textField.endEditing(true)
    }
    
    func configureClassicView() {
        closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        topTitleLabel.textColor = .santanderRed
        shouldShowSmartStyle = false
        stackView.addArrangedSubview(emptyView)
    }
    
    func configureSmartView(mode: PGColorMode) {
        self.configureTextField(smartMode: true)
        configureEmptyViewForSmartStyle()
        configureSearchViewsForSmartStyle()
        self.closeButton.setImage(Assets.image(named: "icnClose")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.closeButton.tintColor = .white
        self.topTitleLabel.textColor = .white
        self.backgroundImageView?.contentMode = .scaleAspectFill
        self.backgroundImageView?.isHidden = false
        self.textFieldBackgroundView.backgroundColor = .clear
        switch mode {
        case .red:
            self.backgroundImageView?.image = Assets.image(named: "icnRedBackground")
        case .black:
            self.backgroundImageView?.image = Assets.image(named: "bgSmartBlack")
        }
        self.topTitleLabel.textColor = .white
    }
    
    func configureSearchViewsForSmartStyle() {
        operativesTitle.setTitleColor(UIColor.white)
        resultsView.setTitleColor(UIColor.white)
        searchedFAQsContainer.backgroundColor = UIColor.lightGray40
        searchedFAQsView.backgroundColor = UIColor.lightGray40
        needHelpForSearchFaqsView.setBackgroundColor(UIColor.lightGray40)
        homeTipsView.setStyle(HelpCenterTipsViewStyle.homeTipsSmartStyle())
        actionsView.backgroundColor = UIColor.lightGray40
    }
    
    func configureEmptyViewForSmartStyle() {
        self.shouldShowSmartStyle = true
        let container = self.emptyView.embedIntoView(topMargin: 11, leftMargin: 15, rightMargin: 15)
        container.isHidden = true
        self.emptyViewContainer = container
        self.stackView.addArrangedSubview(container)
    }
    
    func setSearchResultModel(_ viewModel: OtherOperativesSearchViewModel) {
        showFAQsResults(viewModel.help)
        showGlobalFAQsSearchResults(viewModel.needHelpFor)
        showHomeTipsResults(viewModel.homeTips)
        showActionResults(viewModel.actions)
    }
    
    func setTotalResults(_ results: Int) {
        resultsView.setResults(results)
        stackView.layoutIfNeeded()
    }
    
    func setOperativesResults(_ results: Int) {
        let title = localized("operativeSearch_title_operational",
                              [StringPlaceholder(.number, String(results))])
        operativesTitle.setTitle(title)
    }
    
    func hideTotalResults(_ hide: Bool) {
        resultsView.isHidden = hide
    }
    
    func hideOperativeResults(_ hide: Bool) {
        self.operativesTitle.isHidden = hide
    }
    
    func hideSearchViews(_ hide: Bool) {
        self.operativesTitle.isHidden = hide
        self.resultsView.isHidden = hide
        self.searchedFAQsContainer.isHidden = hide
        self.needHelpForSearchFaqsView.isHidden = hide
        self.homeTipsView.isHidden = hide
        self.actionsView.isHidden = hide
    }
    
    func showFAQsResults(_ faqsResults: [TripFaqViewModel]?) {
        searchedFAQsView.removeSubviews()
        guard let faqsResults = faqsResults, !faqsResults.isEmpty else { return searchedFAQsContainer.isHidden = true }
        searchedFAQsView.setupVieModels(faqsResults)
        searchedFAQsContainer.setNum(faqsResults.count)
        searchedFAQsContainer.isHidden = false
    }
    
    func showGlobalFAQsSearchResults(_ globalFAQsResults: [TripFaqViewModel]?) {
        needHelpForSearchFaqsView.clearFAQs()
        guard let globalFAQsResults = globalFAQsResults, !globalFAQsResults.isEmpty else { return needHelpForSearchFaqsView.isHidden = true }
        needHelpForSearchFaqsView.addFaqs(with: globalFAQsResults)
        needHelpForSearchFaqsView.setNum(globalFAQsResults.count)
        needHelpForSearchFaqsView.isHidden = false
    }
    
    func showHomeTipsResults(_ results: [HelpCenterTipViewModel]?) {
        showHomeTipsResultsNum((results ?? []).count)
        homeTipsView.setViewModels(results ?? [])
        homeTipsView.isHidden = (results ?? []).isEmpty
    }
    
    func showHomeTipsResultsNum(_ num: Int) {
        homeTipsView.setTitle(localized("search_title_tips",
                                        [StringPlaceholder(.number, "\(num)")]))
    }
    
    func showActionResults(_ viewModel: [GlobalSearchActionViewModel]) {
        actionsView.setupVieModels(viewModel)
        actionsView.isHidden = viewModel.isEmpty
    }
}

extension OtherOperativesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textField.endEditing(true)
        textFieldShadowView.layer.shadowOpacity = scrollView.contentOffset.y > 0 ? 0.3 : 0
    }
}

extension OtherOperativesViewController: TripFaqsViewDelegate {
    func didReloadTripFaq() {
        view.endEditing(true)
    }
    
    func didExpandAnswer(question: String) {}
    
    func didTapAnswerLink(question: String, url: URL) {}
}

extension OtherOperativesViewController: HelpCenterTipsViewDelegate {
    func didSelectTip(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
        presenter.didSelectAction(indentifier: viewModel.entity.offer?.id)
    }
    
    func didSelectSeeAllTips() { }
    
    func scrollViewDidEndDecelerating() { }
}

extension OtherOperativesViewController: GlobalSearchActionViewDelegate {
    func didSeletSearchAction(_ identifier: String?, type: GlobalSearchActionViewType) {
        presenter.didSelectAction(identifier: identifier, type: type)
    }
}
