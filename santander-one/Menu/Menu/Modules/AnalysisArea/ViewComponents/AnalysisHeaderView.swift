//
//  AnalysisHeaderView.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 11/03/2020.
//

import UI
import CoreFoundationLib

protocol AnalysysHeaderViewProtocol: AnyObject {
    func didChangedSegmentedWithMonth(_ currentMonth: Int)
    func updateHeaderHeight()
    func defaultHeaderHeight()
    func didTapOnExpenseLabel()
    func didTapOnIncomeLabel()
}

enum AnalysisHeaderHeights: CGFloat {
    typealias RawValue = CGFloat
    case normal = 224.0
    case withPredictiveTooltip = 295.0
    enum TimeLine: CGFloat {
        case timelineLoading = 80.0
    }
}

final class AnalysisHeaderView: UIDesignableView {
    @IBOutlet weak private var segmentControlContainer: UIStackView!
    @IBOutlet weak private var segmentedContainerLeftGap: UIView!
    @IBOutlet weak private var segmentedContainerRightGap: UIView!
    @IBOutlet weak private var segmentedControl: FlatSegmentedControl!
    @IBOutlet weak private var incomeStaticLabel: UILabel!
    @IBOutlet weak private var expenseStaticLabel: UILabel!
    @IBOutlet weak private var incomeLabel: UILabel!
    @IBOutlet weak private var expenseLabel: UILabel!
    @IBOutlet weak var expensePredictiveView: RedToolTipView!
    @IBOutlet weak private var expensePredictiveHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var month1Graph: DualBarGraph!
    @IBOutlet weak private var month2Graph: DualBarGraph!
    @IBOutlet weak private var month3Graph: DualBarGraph!
    @IBOutlet weak private var leftArrowIcon: UIImageView!
    @IBOutlet weak private var rightArrowIcon: UIImageView!
    @IBOutlet weak private var rightArrowIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leftClickableAreaView: UIView!
    @IBOutlet weak private var rightClickableAreaView: UIView!
    
    weak var delegate: AnalysysHeaderViewProtocol?
    private var viewModel: HeaderViewModel?
    /// contains a collection of the bars container. Bar containers are used to center with stackview over each month
    private var barMonthsContainerCollection: [DualBarGraph]?
    /// outline view for selected month.
    private var currentMonthOutLine: OutLineView?
    /// segmented control theme
    private var segmentTheme: FlatSegmentedTheme?
    /// when other month is tapped new instance of OutLineView is created and handled by this variable
    private var monthOutLine: OutLineView?
    /// width of the outline depending of the device
    private let monthOutLineViewVariableWidth: CGFloat = Screen.isScreenSizeBiggerThanIphone5() ? 104.0 : 90.0
    
    private var incomeTapGesture: UITapGestureRecognizer {
        UITapGestureRecognizer(target: self, action: #selector(didTapOnIncome))
    }
    private var expenseTapGesture: UITapGestureRecognizer {
        UITapGestureRecognizer(target: self, action: #selector(didTapOnExpense))
    }
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func commonInit() {
        super.commonInit()
        self.backgroundColor = .white
        self.setupViews()
        setAccessibilityIdentifiers()
        barMonthsContainerCollection = [month1Graph, month2Graph, month3Graph]
        setupIncomeExpenseLabelsTapActions()
    }
    
    public func setSegmentsLabels(localizedKeys: [String], selectedIndex: Int? = nil) {
        if let optionalIndex = selectedIndex {
            self.segmentedControl.selectedSegmentIndex = optionalIndex
        }
    }
    
    public func updateData(_ viewModel: HeaderViewModel) {
        self.viewModel = viewModel
        let segmentTexts = viewModel.pfmMonths()
        self.segmentedControl.updateSegmentsLocalizedTextWithKeys(viewModel.pfmMonths())
        
        if let optionalMonth = viewModel.currentMonth,
           let index = segmentTexts.firstIndex(of: optionalMonth) {
            self.updateExpenseIncomeLabelsAtModelIndex(index)
            self.setupBars()
            self.delegate?.didChangedSegmentedWithMonth(index)
            self.setupExpensePredictiveView()
        }
    }
    
    public func toggleToolTipVisibility(isVisible: Bool) {
        expensePredictiveView.isHidden = !isVisible
    }
    
    func updateExpenseIncomeLabelsAtModelIndex(_ index: Int) {
        guard let data = self.viewModel?.dataForIndex(index) else { return }
        self.showMonthOutLineForSelectedSegmentIndex(index)
        self.segmentedControl.selectedSegmentIndex = index
        incomeLabel.attributedText = data.incomeText
        expenseLabel.attributedText = data.expenseText
    }
    
    func incomesIsEnabled(_ enabled: Bool) {
        guard !enabled else { return }
        self.leftArrowIcon.isHidden = true
        self.leftClickableAreaView.gestureRecognizers?.forEach({ [weak self] in
            self?.leftClickableAreaView.removeGestureRecognizer($0)
        })
    }
    
    func expensesIsEnabled(_ enabled: Bool) {
        guard !enabled else { return }
        self.rightArrowIcon.isHidden = true
        self.rightArrowIconWidthConstraint.constant = 0
        self.rightClickableAreaView.gestureRecognizers?.forEach({ [weak self] in
            self?.rightClickableAreaView.removeGestureRecognizer($0)
        })
    }
}

// MARK: - Private functions
private extension AnalysisHeaderView {
    func setupViews() {
        let theme = FlatSegmentThemeBuilder()
            .setBorderColor(.skyGray)
            .setCornerRadious(4.0)
            .setBackgroundColor(.skyGray)
            .setSelectedTextColor(.darkTorquoise)
            .setSelectedTextFont(.santander(family: .text, type: .bold, size: 15))
            .setUnSelectedTextColor(.lisboaGray)
            .setUnSelectedTextFont(.santander(family: .text, type: .regular, size: 15))
        self.segmentTheme = theme.build()
        styleSegmentedAccordingDevice()
        incomeStaticLabel.text = localized("analysis_label_income")
        expenseStaticLabel.text = localized("analysis_label_expenses")
        incomeStaticLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        expenseStaticLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        self.segmentedControl.addTarget(self, action: #selector(didChangeSegment(sender:)), for: .valueChanged)
        self.leftArrowIcon.image = Assets.image(named: "icnArrowRightPeq")
        self.rightArrowIcon.image = Assets.image(named: "icnArrowRightPeq")
    }
    
    @objc func didChangeSegment(sender: FlatSegmentedControl) {
        self.updateExpenseIncomeLabelsAtModelIndex(sender.selectedSegmentIndex)
        delegate?.didChangedSegmentedWithMonth(sender.selectedSegmentIndex)
    }
    
    func setAccessibilityIdentifiers() {
        segmentedControl.accessibilityIdentifier = AccessibilityAnalysisArea.areaTab.rawValue
        incomeStaticLabel.accessibilityIdentifier = AccessibilityAnalysisArea.labelIncome.rawValue
        expenseStaticLabel.accessibilityIdentifier = AccessibilityAnalysisArea.labelExpense.rawValue
    }
    
    func setupExpensePredictiveView() {
        guard let viewModel = self.viewModel, viewModel.isPredictiveExpense() else { return tooltipIsVisible(false) }
        let rightText = viewModel.expensePredictiveString()
        let leftText = viewModel.expensePredictiveTitle()
        self.expensePredictiveView.textInBubble(leftText: leftText, rightText: rightText)
        let isVisible = Date().isAfterFifteenDaysInMonth() && viewModel.predictiveExpenses() > 0
        tooltipIsVisible(isVisible)
    }
    
    func tooltipIsVisible(_ visible: Bool) {
        self.toggleToolTipVisibility(isVisible: visible)
        if visible {
            delegate?.updateHeaderHeight()
        } else {
            delegate?.defaultHeaderHeight()
        }
    }
    
    /// add a rounded view like a button to the selected moonth
    /// - Parameter index: the index of selected segment
    func showMonthOutLineForSelectedSegmentIndex(_ index: Int) {
        currentMonthOutLine?.removeFromSuperview()
        monthOutLine = OutLineView()
        guard let monthOptionalOutLineView = self.monthOutLine else {
            return
        }
        monthOptionalOutLineView.translatesAutoresizingMaskIntoConstraints = false
        monthOptionalOutLineView.setMonth(viewModel?.monthAtIndex(index) ?? "" )
        self.addSubview(monthOptionalOutLineView)
        let height = monthOptionalOutLineView.heightAnchor.constraint(equalToConstant: 110.0)
        let width = monthOptionalOutLineView.widthAnchor.constraint(equalToConstant: monthOutLineViewVariableWidth)
        let bottom = monthOptionalOutLineView.bottomAnchor.constraint(equalTo: self.segmentedControl.bottomAnchor, constant: -6.0)
        let center = monthOptionalOutLineView.centerXAnchor.constraint(equalTo: self.barContainerForSelectedSegmentIndex(index).centerXAnchor)
        NSLayoutConstraint.activate([height, width, bottom, center])
        self.bringSubviewToFront(monthOptionalOutLineView)
        currentMonthOutLine = monthOutLine
        self.segmentedControl.selectedSegmentIndex = index
    }
    
    /// search for the bars graph corresponding to each segment
    /// - Parameter index: the index of segment
    func barContainerForSelectedSegmentIndex(_ index: Int) -> UIView {
        guard let optionalBarContainers = barMonthsContainerCollection else {
            return UIView()
        }
        return optionalBarContainers[index]
    }
    
    /// create viewmodel and assign delegegate to each graph bars
    func setupBars() {
        guard let optionalViewModel = self.viewModel else {
            return
        }
        for index in 0...optionalViewModel.numberOfMonths {
            if let data = self.viewModel?.dataForIndex(index) {
                let dualGraphViewModel =
                    DualGraphViewModel(entity: data.chartData,
                                       disabledGraph: index != optionalViewModel.numberOfMonths-1 ? .predictive : .none)
                barMonthsContainerCollection?[index].setViewModel(dualGraphViewModel)
                barMonthsContainerCollection?[index].delegate = self
                barMonthsContainerCollection?[index].setNeedsDisplay()
            }
        }
    }
    
    func styleSegmentedAccordingDevice() {
        guard let optionalTheme = self.segmentTheme else {
            return
        }
        if Screen.isScreenSizeBiggerThanIphone5() {
            self.segmentControlContainer.setBackgroundColor(color: optionalTheme.backgroundColor, rounded: true)
            self.segmentedContainerLeftGap.drawBorder(cornerRadius: optionalTheme.cornerRadious,
                                                      color: optionalTheme.backgroundColor,
                                                      width: optionalTheme.borderWidth)
            self.segmentedContainerRightGap.drawBorder(cornerRadius: optionalTheme.cornerRadious,
                                                       color: optionalTheme.backgroundColor,
                                                       width: optionalTheme.borderWidth)
        } else {
            self.segmentControlContainer.removeArrangedSubview(segmentedContainerLeftGap)
            self.segmentControlContainer.removeArrangedSubview(segmentedContainerRightGap)
            self.segmentControlContainer.setBackgroundColor(color: .clear, rounded: false)
            self.segmentedControl.drawBorder(cornerRadius: optionalTheme.cornerRadious,
                                             color: optionalTheme.backgroundColor,
                                             width: optionalTheme.borderWidth)
        }
        self.segmentedControl.setupWithTheme(theme: optionalTheme)
    }
    
    func setupIncomeExpenseLabelsTapActions() {
        self.leftClickableAreaView.addGestureRecognizer(incomeTapGesture)
        self.leftClickableAreaView.isUserInteractionEnabled = true
        self.rightClickableAreaView.addGestureRecognizer(expenseTapGesture)
        self.rightClickableAreaView.isUserInteractionEnabled = true
    }
    
    @objc func didTapOnExpense() {
        self.delegate?.didTapOnExpenseLabel()
    }
    
    @objc func didTapOnIncome() {
        self.delegate?.didTapOnIncomeLabel()
    }
}

extension AnalysisHeaderView: DualBarGraphDelegate {
    func didTapGraphBar(_ bar: DualBarGraph) {
        if let indexOfBarGraph = barMonthsContainerCollection?.firstIndex(of: bar) {
            self.delegate?.didChangedSegmentedWithMonth(indexOfBarGraph)
            self.showMonthOutLineForSelectedSegmentIndex(indexOfBarGraph)
        }
    }
}
