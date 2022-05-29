import UIKit
import UI
import CoreFoundationLib
import IQKeyboardManagerSwift

protocol GlobalSearchViewProtocol: class {
    func setSearchResultModel(from resultViewModels: GlobalSearchViewModel)
    func setReportNumber(_ number: String)
    func showNeedHelpForFAQs(_ viewModel: [TripFaqViewModel])
    func showEmptyView(term: String, suggestedTerm: String?)
    func showInitialHomeTips(_ homeTips: [HelpCenterTipViewModel])
    func showInitialInterestsTips(_ interestsTips: [HelpCenterTipViewModel])
}

enum GlobalSearchViewState {
    case initial
    case empty
    case full
}

final class GlobalSearchViewController: UIViewController {
    private let presenter: GlobalSearchPresenterProtocol
    
    @IBOutlet private weak var topShadowView: UIView!
    @IBOutlet private weak var topStackView: UIStackView!
    @IBOutlet private weak var scrollView: UIView!
    
    private let needHelpTitleHeight: CGFloat = 46.0
    private var suggestedSearchTerm: String?
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView()
        stackView.setup(with: self.scrollView)
        stackView.setScrollDelegate(self)
        return stackView
    }()
    
    private lazy var mainOperativesView: GlobalSearchMainOperativesView = {
        let view = GlobalSearchMainOperativesView()
        view.delegate = self
        view.isUserInteractionEnabled = true
        view.accessibilityIdentifier = "GlobalSearchViewsMainOperativesViewContainer"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        return view
    }()
    
    private lazy var emptyView: SearchEmptyView = {
        let emptyView = SearchEmptyView()
        emptyView.delegate = self
        emptyView.accessibilityIdentifier = "GlobalSearchViewEmptyViewContainer"
        return emptyView
    }()
    
    private lazy var topTitleView: UIView = {
        let view = UIView(frame: .zero)
        
        let titleLabel = UILabel(frame: .zero)
        view.addSubview(titleLabel)
        titleLabel.fullFit(topMargin: 8.0, bottomMargin: 8.0, leftMargin: 24, rightMargin: 24)
        titleLabel.font = UIFont.santander(family: .headline, type: .regular, size: 16)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.set(localizedStylableText: localized("globalSearch_text_needHelp"))
        titleLabel.textColor = .lisboaGray
        titleLabel.accessibilityIdentifier = "globalSearch_text_needHelp"
        view.backgroundColor = .skyGray
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))

        return view
    }()
    
    private lazy var resultsView: GlobalSearchHeaderResults = {
        let view = GlobalSearchHeaderResults()
        view.accessibilityIdentifier = "GlobalSearchViewHeaderResultsViewContainer"
        view.withoutSegmented = !self.presenter.isSegmentedControlViewEnabled
        return view
    }()
    
    private func configureResultView() {
        resultsView.filterAction = { [weak self] res in
            self?.currentFilter = res
            self?.view.endEditing(true)
        }
    }
    
    private lazy var searchBarHeaderView: GlobalSearchHeaderView = {
        let view = GlobalSearchHeaderView()
        view.accessibilityIdentifier = "GlobalSearchViewHeaderViewContainer"
        view.delegate = self
        return view
    }()
    
    private lazy var globalSearchFaqsView: GlobalSearchFaqsView = {
        let view = GlobalSearchFaqsView()
        view.accessibilityIdentifier = "GlobalSearchViewGlobalSearchFAQsViewContainer"
        return view
    }()
    
    private lazy var globalSearchMovementsView: GlobalSearchMovementsView = {
        let view = GlobalSearchMovementsView()
        view.accessibilityIdentifier = "GlobalSearchViewMovementsViewContainer"
        view.delegate = self
        return view
    }()
    
    private lazy var globalSearchMovementsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.accessibilityIdentifier = "GlobalSearchViewMovementsStackViewContainer"
        return stackView
    }()
    
    private lazy var globalSearchActionView: GlobalSearchActionView = {
        let view = GlobalSearchActionView()
        view.accessibilityIdentifier = "GlobalSearchViewSearchActionsViewContainer"
        view.delegate = self
        return view
    }()
    
    lazy var homeTipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 288).isActive = true
        view.setStyle(HelpCenterTipsViewStyle.homeTipsStyle())
        view.setTitleAccessibilityIdentifier("search_title_tips")
        view.accessibilityIdentifier = "GlobalSearchViewHomeTipsViewContainer"
        addBottomSeparatorToView(view)
        return view
    }()
    
    lazy var initialHomeTipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 288).isActive = true
        view.setStyle(HelpCenterTipsViewStyle.homeTipsStyle())
        view.setTitleAccessibilityIdentifier("search_title_tips")
        view.accessibilityIdentifier = "GlobalSearchViewHomeTipsViewContainer"
        addBottomSeparatorToView(view)
        return view
    }()
    
    lazy var initialInterestsTipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyle(HelpCenterTipsViewStyle.interestTipsStyle())
        view.setTitleAccessibilityIdentifier("search_title_interest")
        view.accessibilityIdentifier = "GlobalSearchViewInterestTipsViewContainer"
        return view
    }()
    
    lazy var interestTipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyle(HelpCenterTipsViewStyle.interestTipsStyle())
        view.setTitleAccessibilityIdentifier("search_title_interest")
        view.accessibilityIdentifier = "GlobalSearchViewInterestTipsViewContainer"
        return view
    }()
    
    private lazy var searchedFAQsContainer: NeedHelpForView = {
       let view = NeedHelpForView(topSpace: needHelpTitleHeight)
        view.addSubview(searchedFAQsView)
        view.hideSeparator(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        searchedFAQsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchedFAQsView.topAnchor.constraint(equalTo: view.topAnchor,
                                              constant: needHelpTitleHeight).isActive = true
        searchedFAQsView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: searchedFAQsView.bottomAnchor).isActive = true
        view.accessibilityIdentifier = "GlobalSearchViewSearchFAQsViewContainer"
        return view
    }()
    
    private lazy var searchedFAQsView: TripFaqsView = {
        let view = TripFaqsView(style: .globalSearchStyle)
        view.delegate = self
        return view
    }()
    
    private lazy var needHelpForSearchFaqsView: GlobalSearchFaqsView = {
        let view = GlobalSearchFaqsView()
        view.accessibilityIdentifier = "GlobalSearchViewNeedHelpForSearchFAQsViewContainer"
        return view
    }()
    
    private var viewState: GlobalSearchViewState = .initial {
        didSet {
            evaluateViewState()
        }
    }
    
    private var currentFilter: GlobalSearchFilterType = .all {
        didSet {
            guard currentFilter != oldValue else { return }
            evaluateViewState()
        }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: GlobalSearchPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override var prefersStatusBarHidden: Bool { false }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - private view configuration methods
    
    private func commonInit() {
        configureView()
        configureResultView()
        viewState = .initial
    }
    
    private func configureView() {
        self.view.backgroundColor = UIColor.bg
        topStackView.addArrangedSubview(topTitleView)
        topStackView.addArrangedSubview(searchBarHeaderView)
        scrollableStackView.addArrangedSubview(resultsView)
        scrollableStackView.addArrangedSubview(emptyView)
        scrollableStackView.addArrangedSubview(globalSearchActionView)
        scrollableStackView.addArrangedSubview(globalSearchMovementsView)
        scrollableStackView.addArrangedSubview(globalSearchMovementsStackView)
        scrollableStackView.addArrangedSubview(searchedFAQsContainer)
        scrollableStackView.addArrangedSubview(needHelpForSearchFaqsView)
        if presenter.isMainOperativesViewEnabled { scrollableStackView.addArrangedSubview(mainOperativesView) }
        scrollableStackView.addArrangedSubview(globalSearchFaqsView)
        scrollableStackView.addArrangedSubview(homeTipsView)
        scrollableStackView.addArrangedSubview(initialHomeTipsView)
        scrollableStackView.addArrangedSubview(interestTipsView)
        scrollableStackView.addArrangedSubview(initialInterestsTipsView)
        
        searchBarHeaderView.isHidden = false
        scrollView.backgroundColor = .white
        
        topShadowView.layer.masksToBounds = false
        topShadowView.layer.shadowOffset = CGSize.zero
        topShadowView.layer.shadowColor = UIColor.black.cgColor
        topShadowView.layer.shadowOpacity = 0.3
        topShadowView.layer.shadowRadius = 0.0
    }
    
    private func configureNavigationBar() {
        NavigationBarBuilder( style: .sky,
                              title: .title(key: "toolbar_title_globalSearch"))
            .setLeftAction(.back(action: #selector(backButtonPressed)))
            .setRightActions(.close(action: #selector(closePressed)))
            .build(on: self, with: nil)
    }
    
    @objc private func backButtonPressed() { presenter.goBackAction() }
    @objc private func closePressed() { presenter.closeButtonAction() }
    @objc private func endEditing() { view.endEditing(true) }
}

private extension GlobalSearchViewController {
    func evaluateViewState() {
        topTitleView.isHidden = viewState != .initial
        
        mainOperativesView.isHidden = viewState != .initial
        globalSearchFaqsView.isHidden = globalSearchFaqsView.isEmpty || viewState == .full
        emptyView.isHidden = viewState != .empty
        
        resultsView.isHidden = viewState == .initial
        globalSearchMovementsView.isHidden = viewState != .full
        globalSearchMovementsStackView.isHidden = viewState != .full
        searchedFAQsContainer.isHidden = searchedFAQsView.isEmpty || viewState != .full
        needHelpForSearchFaqsView.isHidden = needHelpForSearchFaqsView.isEmpty || viewState != .full
        globalSearchActionView.isHidden = globalSearchActionView.isEmpty || viewState != .full
        homeTipsView.isHidden = homeTipsView.isEmpty || viewState != .full
        initialHomeTipsView.isHidden = initialHomeTipsView.isEmpty || viewState == .full
        interestTipsView.isHidden = interestTipsView.isEmpty || viewState != .full
        initialInterestsTipsView.isHidden = initialInterestsTipsView.isEmpty  || viewState == .full
        evaluateViewFilter()
    }
    
    func evaluateViewFilter() {
        if viewState == .full {
            globalSearchMovementsView.isHidden = currentFilter != .all || globalSearchMovementsStackView.subviews.isEmpty
            globalSearchMovementsStackView.isHidden = currentFilter != .movement
            searchedFAQsContainer.isHidden = searchedFAQsView.isEmpty || (currentFilter != .all && currentFilter != .help)
            globalSearchActionView.isHidden = globalSearchActionView.isEmpty || (currentFilter != .all && currentFilter != .action)
            needHelpForSearchFaqsView.isHidden = needHelpForSearchFaqsView.isEmpty || (currentFilter != .all && currentFilter != .help)
            homeTipsView.isHidden = homeTipsView.isEmpty || (currentFilter != .all && currentFilter != .help)
            interestTipsView.isHidden = interestTipsView.isEmpty || (currentFilter != .all && currentFilter != .help)
        }
    }
    
    func setHeaderResults(_ results: Int) {
        resultsView.setResults(results)
    }
    
    func showSearchResult(_ resultViewModels: GlobalSearchMovementsGroupViewModel?) {
        guard let resultViewModels = resultViewModels
            else { return globalSearchMovementsView.cleanView() }
        globalSearchMovementsView.addMovements(resultViewModels)
    }
    
    func showGroupedSearchResult(_ resultViewModels: [GlobalSearchMovementsGroupViewModel]?) {
        
        guard let resultViewModels = resultViewModels, !resultViewModels.isEmpty else {
            globalSearchMovementsStackView.removeAllArrangedSubviews()
            return
        }
        
        globalSearchMovementsStackView.removeAllArrangedSubviews()

        for model in resultViewModels {
            let movementsView = GlobalSearchMovementsView()
            movementsView.accessibilityIdentifier = "GlobalSearchViewMovementsViewContainer"
            movementsView.delegate = self
            movementsView.addMovements(model)
            globalSearchMovementsStackView.addArrangedSubview(movementsView)
        }
    }
    
    func showActionsResults(_ results: [GlobalSearchActionViewModel]?) {
        self.globalSearchActionView.setupVieModels(results)
    }
    
    func showFAQsResults(_ faqsResults: [TripFaqViewModel]?) {
        searchedFAQsView.removeSubviews()
        guard let faqsResults = faqsResults, !faqsResults.isEmpty else { return }
        searchedFAQsView.setupVieModels(faqsResults)
        searchedFAQsContainer.setNum(faqsResults.count)
    }
    
    func showInitialHomeTipsResults(_ results: [HelpCenterTipViewModel]?) {
        initialHomeTipsView.setTitle(localized("search_title_tips",
                                        [StringPlaceholder(.number, "\((results ?? []).count)")]))
        initialHomeTipsView.setViewModels(results ?? [])
    }
    
    func showInitialInterestsTipsResults(_ results: [HelpCenterTipViewModel]?) {
        initialInterestsTipsView.setTitle(localized("search_title_interest",
                                        [StringPlaceholder(.number, "\((results ?? []).count)")]))
        initialInterestsTipsView.setViewModels(results ?? [])
    }
    
    func showHomeTipsResults(_ results: [HelpCenterTipViewModel]?) {
        showHomeTipsResultsNum((results ?? []).count)
        homeTipsView.setViewModels(results ?? [])
    }
    
    func showHomeTipsResultsNum(_ num: Int) {
        homeTipsView.setTitle(localized("search_title_tips",
                                        [StringPlaceholder(.number, "\(num)")]))
    }
    
    func showInterestTipsResults(_ results: [HelpCenterTipViewModel]?) {
        showInterestTipsResultsNum((results ?? []).count)
        interestTipsView.setViewModels(results ?? [])
    }
    
    func showInterestTipsResultsNum(_ num: Int) {
        interestTipsView.setTitle(localized("search_title_interest",
                                            [StringPlaceholder(.number, "\(num)")]))
    }
    
    func showGlobalFAQsSearchResults(_ globalFAQsResults: [TripFaqViewModel]?) {
        needHelpForSearchFaqsView.clearFAQs()
        guard let globalFAQsResults = globalFAQsResults, !globalFAQsResults.isEmpty else { return }
        needHelpForSearchFaqsView.addFaqs(with: globalFAQsResults)
        needHelpForSearchFaqsView.setNum(globalFAQsResults.count)
    }
    
    func addBottomSeparatorToView(_ view: UIView) {
        let separator = UIView()
        separator.backgroundColor = UIColor.mediumSkyGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: separator.bottomAnchor).isActive = true
    }
}

extension GlobalSearchViewController: GlobalSearchHeaderViewDelegate {
    func textFieldDidSet(text: String) {
        if text.isEmpty { viewState = .initial }
        topTitleView.isHidden = text.count > 0
        currentFilter = .all
        presenter.textFieldDidSet(text: text)
    }
    
    func touchAction() { view.endEditing(true) }
    
    func clearIconAction() {
        view.endEditing(true)
        textFieldDidSet(text: "")
    }
}

extension GlobalSearchViewController: GlobalSearchViewProtocol {
    
    func showEmptyView(term: String, suggestedTerm: String?) {
        suggestedSearchTerm = suggestedTerm
        setHeaderResults(0)
        showSearchResult(nil)
        showGroupedSearchResult(nil)
        showFAQsResults(nil)
        showGlobalFAQsSearchResults(nil)
        showActionsResults(nil)
        showHomeTipsResults(nil)
        showInterestTipsResults(nil)
        emptyView.searchTerm = term
        emptyView.updateSuggestedSearchTermWith(suggestedTerm ?? "")
        viewState = .empty
        self.presenter.didSetEmptyView()
    }
    
    func setSearchResultModel(from resultViewModels: GlobalSearchViewModel) {
        setHeaderResults(resultViewModels.totalResult)
        showSearchResult(resultViewModels.allMovements())
        showGroupedSearchResult(resultViewModels.groupedMovements())
        showActionsResults(resultViewModels.actions)
        showFAQsResults(resultViewModels.help)
        showGlobalFAQsSearchResults(resultViewModels.needHelpFor)
        showHomeTipsResults(resultViewModels.homeTips)
        showInterestTipsResults(resultViewModels.interestTips)
        emptyView.searchTerm = resultViewModels.searchTerm
        emptyView.updateSuggestedSearchTermWith("")
        
        resultsView.setSegments(resultViewModels.associatedSegments())
        
        viewState = resultViewModels.totalResult > 0 ? .full : .empty   
    }
    
    func showNeedHelpForFAQs(_ viewModel: [TripFaqViewModel]) {
        globalSearchFaqsView.delegate = self
        globalSearchFaqsView.addFaqs(with: viewModel)
        evaluateViewState()
    }
    
    func setReportNumber(_ number: String) {
        mainOperativesView.setReportNumber(number)
    }
    
    func showInitialHomeTips(_ homeTips: [HelpCenterTipViewModel]) {
        showInitialHomeTipsResults(homeTips)
        evaluateViewState()
    }
    
    func showInitialInterestsTips(_ interestsTips: [HelpCenterTipViewModel]) {
        showInitialInterestsTipsResults(interestsTips)
        evaluateViewState()
    }
}

extension GlobalSearchViewController: GlobalSearchMainOperativesViewDelegate {
    func didSelect(action: GlobalSearchButtonAction) {
        view.endEditing(true)
        switch action {
        case .reportDuplicate:
            presenter.reportDuplicateMovementAction()
        case .returnReceipt:
            presenter.returnBillAction()
        case .reuseTransfer:
            presenter.reuseTransferAction()
        case .turnOffCard:
            presenter.switchOffCardAction()
        }
    }
}

extension GlobalSearchViewController: GlobalSearchMovementActionsDelegate {
    func didSelectMovement(at index: Int, groupedBy productId: String?, of type: GlobalSearchMovementType) {
        view.endEditing(true)
        presenter.didSelectMovement(at: index, groupedBy: productId, of: type)
    }
}

extension GlobalSearchViewController: TripFaqsViewDelegate {
    func didReloadTripFaq() {
        view.endEditing(true)
    }
    
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension GlobalSearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        topShadowView.layer.shadowRadius = scrollView.contentOffset.y > 0.0 ? 2.0 : 0.0
    }
}

extension GlobalSearchViewController: SearchEmptyViewDelegate {
    func maybeYouWantedToSayAction() {
        view.endEditing(true)
        guard let term = suggestedSearchTerm else { return }
        searchBarHeaderView.updateTexField(text: term)
    }
}

extension GlobalSearchViewController: GlobalSearchActionViewDelegate {
    func didSeletSearchAction(_ identifier: String?, type: GlobalSearchActionViewType) {
        self.presenter.didSelectAction(identifier: identifier, type: type)
    }
}

extension GlobalSearchViewController: HelpCenterTipsViewDelegate {
    func didSelectTip(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
        presenter.didSelectAction(identifier: viewModel.entity.offer?.id)
    }
    
    func didSelectSeeAllTips() { }
    
    func scrollViewDidEndDecelerating() { }
}
