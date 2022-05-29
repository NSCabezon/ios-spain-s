import UIKit
import CoreFoundationLib
import UI
import CoreDomain

protocol AnalysisAreaViewProtocol: AnyObject {
    func headerDataReady(viewModel: HeaderViewModel)
    func carouselDataReady(viewModel: AnalysisCarouselViewModel)
    func showLoading()
    func dismissLoading()
    var loadingTipsViewController: LoadingTipViewController? { get set }
    func timeLineDataReady(viewModel: TimeLineViewModel)
    func hideTimeLineLoading()
    func loadOfferBanners(_ location: AnalysisAreaLocations, viewModel: OfferBannerViewModel)
    func showSavingTipsCurtainView(savingTips: [SavingTipViewModel], index: Int)
    func setSavingTips(_ savingTips: [SavingTipViewModel])
    func showEditBudgetView(editBudget: EditBudgetEntity, originView: UIView)
    func showPiggyBankView(_ piggyBanks: AccountEntity?)
    func setFinancialHealth(_ financialHealthViewModel: FinancialHealthViewModel)
    func setFinancialHealthViewHidden(_ isHidden: Bool)
    func hideSavingTipsView()
    func incomesIsEnabled(_ enabled: Bool)
    func expensesIsEnabled(_ enabled: Bool)
    func hideCushionTipsView()
    func showCushionTipsView(_ offerCustomTip: OfferCustomTipViewModel, action: (() -> Void)?)
    func hideBudgetTipsView()
    func showBudgetTipsView(_ offerCustomTip: OfferCustomTipViewModel, action: (() -> Void)?)
}

final class OldAnalysisAreaViewController: UIViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var headerView: AnalysisHeaderView!
    @IBOutlet weak private var carouselCollectionView: AnalysisCarouselView!
    @IBOutlet weak private var totalSavingView: TotalSavingsView!
    @IBOutlet weak private var tipsOfferView: OfferBannerView!
    @IBOutlet weak private var moneyPlanOffer: OfferBannerView!
    @IBOutlet weak private var savingTipsView: SavingTipsView!
    @IBOutlet weak private var timeLineView: TimeLineView!
    @IBOutlet weak private var timelineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var totalSavingsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var financialHealthView: FinancialHealthView!
    @IBOutlet weak private var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var piggyBoxView: YourMoneyBoxView!
    @IBOutlet weak private var piggyBoxHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var tipsOfferViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var moneyPlanViewHeightConstraint: NSLayoutConstraint!

    private var bottomBackgroundColor: UIColor = .white
    let presenter: AnalysisAreaPresenterProtocol
    var loadingTips: LoadingTipViewController?
    private var headerViewModel: HeaderViewModel?
    
    init(nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?,
         presenter: AnalysisAreaPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .skyGray
        carouselCollectionView.backgroundColor = .lightGray40
        self.separatorView.backgroundColor = .mediumSkyGray
        configureDelegates()
        presenter.viewDidLoad()
        self.headerView.delegate = self
        self.scrollView.delegate = self
        self.tipsOfferView.isHidden = true
        self.piggyBoxView.isHidden = true
        self.separatorView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeToolTipBubbleIfNeeded()
    }
    
    private func showTipLoading() {
        let parent = self
        guard let child = loadingTips else { return }
        parent.view.addSubview(child.view)
        child.view.fullFit()
        parent.addChild(child)
        child.didMove(toParent: parent)
    }
    
    private func hideTipLoading() {
        guard let child = loadingTips else { return }
        child.willMove(toParent: nil)
        child.removeFromParent()
        child.view.removeFromSuperview()
    }

    func setSavingTips(_ savingTips: [SavingTipViewModel]) {
        savingTipsView.setSavingTips(savingTips)
        bottomBackgroundColor = .blueAnthracita
    }
    
    func hideSavingTipsView() {
        savingTipsView.isHidden = true
        bottomBackgroundColor = .white
    }
    
    func setFinancialHealth(_ financialHealthViewModel: FinancialHealthViewModel) {
        financialHealthView.setFinancialHealth(financialHealthViewModel)
        financialHealthView.delegate = self
    }
    
    func setFinancialHealthViewHidden(_ isHidden: Bool) {
        financialHealthView.isHidden = isHidden
    }
    
    func hideCushionTipsView () {
        financialHealthView.hideTipsView()
    }
    
    func showCushionTipsView(_ offerCustomTip: OfferCustomTipViewModel, action: (() -> Void)?) {
        financialHealthView.setTipStackView(offerCustomTip, action: action)
    }
    
    func hideBudgetTipsView() {
        carouselCollectionView.hideFinancialBudgetTip()
    }
    
    func showBudgetTipsView(_ offerCustomTip: OfferCustomTipViewModel, action: (() -> Void)?) {
        carouselCollectionView.showFinancialBudgetTip(offerCustomTip, action: action)
    }
}

extension OldAnalysisAreaViewController: AnalysysHeaderViewProtocol {
    func didTapOnIncomeLabel() {
        guard let entity = self.headerViewModel?.monthlyBalanceForIndex(presenter.selectedMonthAsSegmentIndex) else {
            return
        }
        self.presenter.loadReportForMovementType(.incomes, pfmMonth: entity)
    }
    
    func didTapOnExpenseLabel() {
        guard let entity = self.headerViewModel?.monthlyBalanceForIndex(presenter.selectedMonthAsSegmentIndex) else {
            return
        }
        self.presenter.loadReportForMovementType(.expenses, pfmMonth: entity)
    }
    
    func defaultHeaderHeight() {
        self.headerView?.expensePredictiveView.isHidden = true
        self.headerView.toggleToolTipVisibility(isVisible: false)
        self.headerViewHeightConstraint.constant = AnalysisHeaderHeights.normal.rawValue
    }
    
    func updateHeaderHeight() {
        self.headerView.toggleToolTipVisibility(isVisible: true)
        self.headerViewHeightConstraint.constant = AnalysisHeaderHeights.withPredictiveTooltip.rawValue
    }
    
    // MARK: - Function to update views with information of current month
    func didChangedSegmentedWithMonth(_ currentMonth: Int) {
        presenter.didChangedSegmentedWithMonth(currentMonth)
        let pfmMonth = headerViewModel?.monthlyBalanceForIndex(currentMonth)
        self.updateHeightsWithSelectedMonth(currentMonth)
        self.timeLineView.clearDataSource()
        if let optionalDate = pfmMonth?.date {
            self.timeLineView.viewDelegate?.showLoading()
            self.presenter.loadTimeLineStartingWith(optionalDate)
            self.headerView.updateExpenseIncomeLabelsAtModelIndex(currentMonth)
        }
    }
}

extension OldAnalysisAreaViewController: AnalysisAreaViewProtocol {
    func loadOfferBanners(_ location: AnalysisAreaLocations, viewModel: OfferBannerViewModel) {
        self.separatorView.isHidden = false
        switch location {
        case .customTip:
            self.tipsOfferView.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: tipsOfferViewHeightConstraint)
            self.tipsOfferView.backgroundColor = .skyGray
        case .moneyPlan:
            self.moneyPlanOffer.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: moneyPlanViewHeightConstraint)
            self.moneyPlanOffer.backgroundColor = .skyGray
        case .piggyBank:
            let bannerView = piggyBoxView.bannerView()
            switch self.headerViewModel?.isPiggyBanner {
            case false:
                bannerView.isHidden = true
            default:
                bannerView.setOfferBannerForLocation(viewModel: viewModel, updateConstraint: piggyBoxHeightConstraint)
                self.piggyBoxView.isHidden = false
            }
        }
    }
    
    func hideTimeLineLoading() {
        self.timelineHeightConstraint.constant = 0
        self.timeLineView.dismissLoading()
    }
    
    func timeLineDataReady(viewModel: TimeLineViewModel) {
        self.timeLineView.viewDelegate?.dismissLoading()
        self.timeLineView.viewDelegate?.didUpdateData(viewModel)
        let elements = viewModel.getDataForMonth(viewModel.currentMonth)
        let timelineHeight = TimeLineMovementCell.cellHeight * CGFloat(elements.count)
        self.timelineHeightConstraint.constant = CGFloat(timelineHeight)
    }
    
    var loadingTipsViewController: LoadingTipViewController? {
        get {
            return loadingTips
        }
        set {
            loadingTips = newValue
        }
    }
    
    func dismissLoading() {
        hideTipLoading()
    }
    
    func showLoading() {
        showTipLoading()
    }
    
    func headerDataReady(viewModel: HeaderViewModel) {
        self.headerViewModel = viewModel
        self.headerView.updateData(viewModel)
        self.updateTotalSavingsViewWithTotal(viewModel.totalSaving(), months: viewModel.pfmMonths())
    }
    
    func carouselDataReady(viewModel: AnalysisCarouselViewModel) {
        self.carouselCollectionView.setViewModel(viewModel, delegateBudget: self, delegateBudgetCell: self)
    }
    
    func showSavingTipsCurtainView(savingTips: [SavingTipViewModel], index: Int) {
        guard !(view.window?.subviews.contains { $0 is SavingTipsCurtainView } ?? false) else { return }
        
        let savingTipsCurtainView = SavingTipsCurtainView(frame: UIScreen.main.bounds)
        savingTipsCurtainView.delegate = self
        savingTipsCurtainView.setSavingTips(savingTips)
        savingTipsCurtainView.setDataOfIndex(index)
        
        if let newIndex = savingTipsCurtainView.scrollToIndex(index + 1) {
            self.savingTipsView.scrollToIndex(newIndex, animated: false)
        }
        view.window?.addSubview(savingTipsCurtainView)
    }
    
    func showEditBudgetView(editBudget: EditBudgetEntity, originView: UIView) {
        guard !(view.window?.subviews.contains { $0 is EmptyBubbleView } ?? false) else { return }
        
        let budgetView = BudgetBubbleView(frame: CGRect(x: 0, y: 0, width: 256, height: 248))
        budgetView.setBudget(editBudget)
        budgetView.delegate = self
        let emptyBubbleView = EmptyBubbleView(associated: originView, addedView: budgetView)
        budgetView.closeAction = emptyBubbleView.getCloseAction()
        
        emptyBubbleView.setBottomViewWithKeyboard(budgetView.saveButton)
        emptyBubbleView.addCloseCourtain(view: view.window)
        view.window?.addSubview(emptyBubbleView)
    }
    
    func showPiggyBankView(_ piggyBanks: AccountEntity?) {
        self.headerViewModel?.isPiggyBanner = piggyBanks == nil
        if self.headerViewModel?.isPiggyBanner == true {
            // Default piggyBank - Banner
            self.piggyBoxView.configBannerView()
        } else {
            // Available piggyBank
            guard let amount = piggyBanks?.amountUI,
                let decimalValue = Decimal(string: amount),
                let attributedString = headerViewModel?.piggyBankAmountString(decimalValue: decimalValue) else {
                return
            }
           
            let bannerView = piggyBoxView.bannerView()
            bannerView.isHidden = true
            self.piggyBoxView.configAvailableView(localized("analysis_label_yourPiggy"), attributedString)

            Async.after(seconds: 1.0) {
                self.piggyBoxHeightConstraint.constant = 105
                self.piggyBoxView.layoutIfNeeded()
                self.piggyBoxView.isHidden = false
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func incomesIsEnabled(_ enabled: Bool) {
        headerView.incomesIsEnabled(enabled)
    }
    
    func expensesIsEnabled(_ enabled: Bool) {
        headerView.expensesIsEnabled(enabled)
    }
}

extension OldAnalysisAreaViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return .analysisArea
    }
}

extension OldAnalysisAreaViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

private extension OldAnalysisAreaViewController {
    func updateHeightsWithSelectedMonth(_ month: Int) {
        if Date().isAfterFifteenDaysInMonth() {
            guard let viewModel = self.headerViewModel else { return }
            self.timelineHeightConstraint.constant = CGFloat(AnalysisHeaderHeights.TimeLine.timelineLoading.rawValue)
            let lastMonth = viewModel.numberOfMonths - 1
            self.headerViewHeightConstraint.constant = (month == lastMonth)
                ? AnalysisHeaderHeights.withPredictiveTooltip.rawValue
                : AnalysisHeaderHeights.normal.rawValue
            let isVisible = month == lastMonth
            self.headerView.toggleToolTipVisibility(isVisible: isVisible)
        } else {
            self.headerView.toggleToolTipVisibility(isVisible: false)
        }
    }
    
    func configureDelegates() {
        self.headerView.delegate = self
        self.tipsOfferView.delegate = self
        self.moneyPlanOffer.delegate = self
        self.piggyBoxView.delegate = self
        savingTipsView.setDelegate(presenter as? SavingTipCollectionViewControllerDelegate)
        savingTipsView.setCollectionViewDelegate(presenter as? SavingTipCollectionViewDelegate)
        timeLineView.delegate = self
    }
    
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "menu_link_tips")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func removeToolTipBubbleIfNeeded() {
        if let bubbles = view.window?.subviews.compactMap({ $0 as? EmptyBubbleView}) {
            bubbles.forEach({ $0.dismiss() })
        }
        
        if let bubbles = view.window?.subviews.compactMap({ $0 as? SavingTipsCurtainView}) {
            bubbles.forEach({ $0.removeFromSuperview() })
        }
    }

    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    func updateTotalSavingsViewWithTotal(_ total: Decimal, months: [String]) {
        guard total > 0 else {
            self.totalSavingsHeightConstraint.constant = 0
            return
        }
        let viewModel = TotalSavingsViewModel(months: months, amount: total)
        self.totalSavingView.updateInfoWith(viewModel)
    }
}

extension OldAnalysisAreaViewController: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectedOffer(viewModel)
    }
}

extension OldAnalysisAreaViewController: SavingTipsCurtainViewDelegate {
    func didScrollToIndex(_ index: Int) {
        savingTipsView.scrollToIndex(index, animated: false)
    }
}

extension OldAnalysisAreaViewController: CreateBudgetCollectionViewCellDelegate, AnalysisCarouselCollectionViewCellDelegate {
    func didPressBudgetCell(originView: UIView, newBudget: Bool) {
        carouselCollectionView.moveBudgetCell {
            self.presenter.didSelectBudget(originalView: originView, newBudget: newBudget)
        }
    }
}

extension OldAnalysisAreaViewController: BudgetBubbleViewProtocol {
    func didShowBudget() {}
    
    func didChangedSlide() {}
    
    func didPressSaveButton(budget: Double) {
        presenter.didPressSaveButton(budget: budget)
    }
}

extension OldAnalysisAreaViewController: FinancialHealthViewDelegate {
    func didExpandFinancialHealthView() {
        presenter.didExpandFinancialHealthView()
    }
}

extension OldAnalysisAreaViewController: TimeLineViewDelegate {
    func didSelectCellType(_ expenseType: ExpenseType) {
        presenter.didSelectTimelineCellType(expenseType)
    }    
}

extension OldAnalysisAreaViewController: YourMoneyBoxDelegate {
    func didTapInBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectedOffer(viewModel)
    }
}

extension OldAnalysisAreaViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.backgroundColor = scrollView.contentOffset.y >= 0 ?
            bottomBackgroundColor : .skyGray
    }
}

extension OldAnalysisAreaViewController: GenericErrorDialogPresentationCapable {
    var associatedGenericErrorDialogView: UIViewController {
        self.navigationController?.topViewController ?? UIViewController()
    }
}
