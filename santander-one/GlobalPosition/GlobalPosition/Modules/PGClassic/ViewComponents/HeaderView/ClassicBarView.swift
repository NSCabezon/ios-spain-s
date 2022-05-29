import UIKit
import CoreFoundationLib
import UI

struct ExpensesBarInfo {
    let topTitle: String
    let barSize: Float
    let bottomTitle: String
    let blurred: Bool
    let monthInfo: String
}

final class ClassicBarView: DesignableView {
    
    @IBOutlet weak var barsContainerStackView: UIStackView!
    @IBOutlet weak var graphContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstReferenceLabel: UILabel!
    @IBOutlet weak var secondReferenceLabel: UILabel!
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var firstReferenceImageView: UIImageView!
    @IBOutlet weak var secondReferenceImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var financialStatusView: FinantialStatusView!
    
    @IBOutlet private weak var topChartConstraint: NSLayoutConstraint!
    var dashLineBottomConstraint: NSLayoutConstraint?
    @IBOutlet private weak var graphContainerButton: UIButton!
    
    private var bars: [ClassicGradientColumn] = []
    var onSetLimits: (() -> Void)?
    var onTapGraph: (() -> Void)?
    
    private let toolTipDismissDuration = 4.0
    private var dashLine: DashLineButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func viewWillAppear() {
        loadingImageView.restartIfNecessary()
        setupLabels()
    }
    
    private func setupView() {
        loadingImageView.setPointsLoader()

        dashLine = DashLineButton(style: .classic)
        guard let dashLine = dashLine else { return }
        
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        dashLine.editButtonAction = { [weak self] in
            self?.onSetLimits?()
        }

        graphContainerView.addSubview(dashLine)
        dashLine.leftAnchor.constraint(equalTo: graphContainerView.leftAnchor).isActive = true
        dashLine.rightAnchor.constraint(equalTo: graphContainerView.rightAnchor).isActive = true
        dashLineBottomConstraint = dashLine.bottomAnchor.constraint(equalTo: graphContainerView.bottomAnchor)
        dashLineBottomConstraint?.isActive = true
                
        titleLabel.font = .santander(family: .headline, type: .bold, size: 13)
        titleLabel.textColor = UIColor.lisboaGray
        firstReferenceLabel.font = .santander(family: .text, type: .bold, size: 12)
        firstReferenceLabel.textColor = UIColor.lisboaGray
        secondReferenceLabel.font = .santander(family: .text, type: .bold, size: 12)
        secondReferenceLabel.textColor = UIColor.lisboaGray

        setupLabels()
        setAccessibility(setViewAccessibility: self.setAccessibility)
        setAccessibilityIdentifiers()
    }
    
    @IBAction func didTapOnGraph(_ sender: Any) {
        self.onTapGraph?()
    }
    
    fileprivate func setupLabels() {
        setFirstReference(localized("pg_label_budget"))
        setSecondReference(localized("pg_label_expenses"))
        setTitle(localized("pg_label_yourExpenses"))
        firstReferenceImageView.image = Assets.image(named: "icnBudgetGP")
        secondReferenceImageView.image = Assets.image(named: "icnExpensesGP")
        tooltipButton.setImage(Assets.image(named: "icnInfoBlueClassic"), for: .normal)
        dashLine?.buttonLabel.text = localized("pg_label_objective")
        dashLine?.layoutIfNeeded()
    }
    
    func setBarData(_ barsData: [ExpensesBarInfo], budgetSize: Float, predictiveExpense: Decimal?, predictiveExpenseSize: Float?) {
        setDashLinePosition(budgetSize: budgetSize, predictiveExpenseSize: predictiveExpenseSize)

        loadingImageView.removeLoader()
        loadingView.isHidden = true
        bars.removeAll()
        barsContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        barsData.enumerated().forEach { index, element in
            if index > 0 {
                let spacer = ClassicSpacerColumn()
                spacer.setBaseLineColor(UIColor.darkRedGraphic)
                barsContainerStackView.addArrangedSubview(spacer)
            }
            let bar = ClassicGradientColumn()
            bar.setupWith(element, contentHeight: self.graphContainerView.frame.height - topChartConstraint.constant)
            self.bars.append(bar)
            barsContainerStackView.addArrangedSubview(bar)
        }
        self.bars.last?.setBottomLabelFont(UIFont.santander(family: .text, type: .bold, size: 12), color: .black)
        
        if let predictiveExpenseSize = predictiveExpenseSize {
            setPredictiveSize(predictiveExpense: predictiveExpense, predictiveSize: CGFloat(predictiveExpenseSize))
        }
    }
    
    func setTitle(_ text: LocalizedStylableText) {
        titleLabel.configureText(withLocalizedString: text)
    }
    
    func setFirstReference(_ text: String) {
        firstReferenceLabel.text = text
    }

    func setSecondReference(_ text: String) {
        secondReferenceLabel.text = text
    }
    
    func show(_ animated: Bool, isBigWhatsNewBubble: Bool) {
        self.bars.enumerated().forEach {
            let item = $0
            if animated {
                let delay: TimeInterval = (Double(0.2) * Double($0.offset))
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self else { return }
                    item.element.show(animated)
                    if item.offset == self.bars.endIndex - 1 {
                        let extraDelay: Double = isBigWhatsNewBubble ? 4 : 0
                        self.showPredictiveExpenseTooltip(delay: delay + extraDelay)
                    }
                }
            } else {
                item.element.show(animated)
            }
        }
    }
    
    @IBAction func didPressTooltip(_ sender: UIButton) {
        BubbleLabelView.startWith(associated: sender, text: localized("tooltip_title_budgetYourExpenses"), position: .bottom)
    }
    
    func showEditBudgetView(editBudget: EditBudgetEntity, delegate: BudgetBubbleViewProtocol?) {
        guard !(window?.subviews.contains { $0 is EmptyBubbleView } ?? false) else { return }
        guard let tapView = dashLine?.tapView else { return }
        
        let budgetView = BudgetBubbleView(frame: CGRect(x: 0, y: 0, width: 256, height: 248))
        budgetView.setBudget(editBudget)
        budgetView.delegate = delegate
        let emptyBubbleView = EmptyBubbleView(associated: tapView, addedView: budgetView)
        budgetView.closeAction = emptyBubbleView.getCloseAction()
        
        emptyBubbleView.setBottomViewWithKeyboard(budgetView.saveButton)
        emptyBubbleView.addCloseCourtain(view: window)
        window?.addSubview(emptyBubbleView)
        UIAccessibility.post(notification: .screenChanged, argument: emptyBubbleView)
        let announcement: String = localized("voiceover_popupWindow")
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
}

private extension ClassicBarView {
    
    func setDashLinePosition(budgetSize: Float, predictiveExpenseSize: Float?) {
        // MARK: Resize or not de chart in relation of budgetSize
        
        let dashLineHeight: CGFloat = dashLine?.frame.height ?? 42.0
        let minTopConstant: CGFloat = dashLineHeight/2
        
        let exampleBar = ClassicGradientColumn()
        let minHeightGradientColumn: CGFloat = exampleBar.bottomLabel.frame.height + exampleBar.baseLineView.frame.height
        let maxContentSpace = graphContainerView.frame.height - minHeightGradientColumn
        let resizeConstantBudget = maxContentSpace - min(CGFloat(1/budgetSize) * (maxContentSpace - dashLineHeight/2), maxContentSpace)
        let newConstant = budgetSize > 1 ? resizeConstantBudget : minTopConstant
        topChartConstraint.constant = min(newConstant, maxContentSpace)
        
        // MARK: Set DashLine position in relation of budgetSize

        let maxDashLinePosition = graphContainerView.frame.height - dashLineHeight
        let minDashLinePosition = minHeightGradientColumn - dashLineHeight/2 - 1
        let newContentSpace = graphContainerView.frame.height - newConstant - minHeightGradientColumn
        let dashHeightRelationBudget = newContentSpace * CGFloat(budgetSize) + minDashLinePosition - 1
        let dashLinePosition: CGFloat = budgetSize >= 1 ? maxDashLinePosition : dashHeightRelationBudget
        
        dashLineBottomConstraint?.constant = -max(minDashLinePosition, min(maxDashLinePosition, dashLinePosition))
        
        checkDashLineLabelPosition(dashLineBottomConstraint?.constant ?? 0.0, minDashLinePosition: minDashLinePosition, dashLineHeight: dashLine?.tapView.frame.height ?? 0.0)
    }
    
    func checkDashLineLabelPosition(_ position: CGFloat, minDashLinePosition: CGFloat, dashLineHeight: CGFloat) {
        if -position <= minDashLinePosition + dashLineHeight/2 {
            dashLine?.moveLabelCenterPosition(dashLineHeight/2 + position + minDashLinePosition)
        } else {
            dashLine?.moveLabelCenterPosition(0.0)
        }
    }
    
    func setPredictiveSize(predictiveExpense: Decimal?, predictiveSize: CGFloat) {
        let contentHeight = graphContainerView.frame.height - topChartConstraint.constant
        if contentHeight * predictiveSize > graphContainerView.frame.height + (bars.last?.bottomLabel.frame.height ?? 0.0) {
            self.bars.last?.setMaxPredictiveBarHeight(graphContainerView.frame.height )
        } else {
            self.bars.last?.setPredictiveBarHeight(predictiveSize, contentHeight: contentHeight)
        }
        
        self.bars.last?.predictiveExpense = predictiveExpense
    }
    
    func showPredictiveExpenseTooltip(delay: TimeInterval) {
        guard let lastBar = self.bars.last,
              let predictiveExpense = lastBar.predictiveExpense,
              predictiveExpense > Decimal.zero
        else { return }
        
        let bubbleViews = self.subviews.flatMap {
            $0.allSubViewsOf(type: BubbleLabelView.self)
        }
        guard bubbleViews.count == 0 else {
            print("Warning: The BubbleLabelView view has already been added to the subviews tree. \(bubbleViews)")
            return
        }
            
        let amountString = AmountEntity(value: lastBar.predictiveExpense ?? Decimal.zero).getStringValue(withDecimal: 0)
        let styledText: LocalizedStylableText = localized("pg_tooltip_predictiveSpending",
                                                          [(StringPlaceholder(.value, amountString))])
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self,
                  let tapView = lastBar.predictiveTooltipAreaView
            else { return }
            BubbleLabelView.startInSuperviewWith(associated: tapView,
                                                 text: styledText.text,
                                                 position: .right,
                                                 dismissDuration: self.toolTipDismissDuration,
                                                 superview: self)
        }
    }
    
    func setAccessibility() {
        self.titleLabel.isAccessibilityElement = false
        self.setAccessibilityGraph()
        self.setAccessibilityDashLine()
        self.accessibilityElements = [self.financialStatusView as UIView, self.graphContainerButton as UIView, self.graphContainerView as UIView]
    }
    
    func setAccessibilityGraph() {
        self.graphContainerButton.isAccessibilityElement = true
        self.graphContainerButton.accessibilityLabel = localized("voiceover_expenseChart")
        self.graphContainerButton.accessibilityTraits = .button
    }
    
    func setAccessibilityDashLine() {
        self.dashLine?.buttonLabel.isAccessibilityElement = true
        self.dashLine?.buttonLabel.accessibilityLabel = localized("pg_label_objective")
        self.dashLine?.buttonLabel.accessibilityTraits = .button
    }
    
    func setAccessibilityIdentifiers() {
        self.dashLine?.buttonLabel.restorationIdentifier = AccessibilityGlobalPosition.objetiveButton
        self.graphContainerButton.accessibilityIdentifier = AccessibilityGlobalPosition.graphContainer
        self.titleLabel.accessibilityIdentifier = AccessibilityGlobalPosition.titleBarLabel
        self.firstReferenceLabel.accessibilityIdentifier = AccessibilityGlobalPosition.firstBarReference
        self.secondReferenceLabel.accessibilityIdentifier = AccessibilityGlobalPosition.secondBarReference
        self.tooltipButton.accessibilityIdentifier = AccessibilityGlobalPosition.tooltipBar
        self.loadingView.accessibilityIdentifier = AccessibilityGlobalPosition.loadingBarView
        self.loadingImageView.accessibilityIdentifier = AccessibilityGlobalPosition.loadingBarImage
    }
}

extension ClassicBarView {
    func setFinantialStatusInfo(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        financialStatusView.isHidden = false
        
        setYourBalanceSelected(totalBalance: totalBalance, financingTotal: financingTotal, tooltipText: tooltipText)
    }
    
    func setDiscreteMode(_ enabled: Bool) { financialStatusView.setDiscreteMode(enabled) }
    
    private func setYourBalanceSelected(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        let totalBalanceData: FinantialStatusData
        let financingTotalData: FinantialStatusData
        
        let selectedYourBalanceTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.grafite, .font: UIFont.santander(family: .text, type: .regular, size: 14.0)]
        let unselectedTextStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.grafite, .font: UIFont.santander(family: .text, type: .regular, size: 14.0)]
        let subtitleSelectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lisboaGray, .font: UIFont.santander(family: .text, type: .bold, size: 20.0)]
        let subtitleUnselectedStyle: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.grafite, .font: UIFont.santander(family: .text, type: .bold, size: 16.0)]
        
        if let totalBalance = totalBalance {
            totalBalanceData = FinantialStatusAmount(amount: totalBalance,
                                                     integerFont: UIFont.santander(type: .bold, size: 26.0),
                                                     decimalSize: 20.0,
                                                     color: .lisboaGray)
        } else {
            totalBalanceData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleSelectedStyle))
        }
        
        if let financingTotal = financingTotal {
            financingTotalData = FinantialStatusAmount(amount: financingTotal,
                                                       integerFont: UIFont.santander(type: .bold, size: 22.0),
                                                       decimalSize: 16.0,
                                                       color: .lisboaGray)
        } else {
            financingTotalData = FinantialStatusText(text: NSAttributedString(string: localized("pgBasket_label_differentCurrency").text, attributes: subtitleUnselectedStyle))
        }
        
        let totalBalanceTitle = NSAttributedString(string: localized("pg_label_totMoney"), attributes: selectedYourBalanceTextStyle)
        let financingTitle = NSAttributedString(string: localized("pg_label_totFinancing"), attributes: unselectedTextStyle)
        
        financialStatusView.setLeftData(title: totalBalanceTitle, subtitle: totalBalanceData.getFormattedString(), tooltipStyle: .red, tooltipText: tooltipText)
        financialStatusView.setRightData(title: financingTitle, subtitle: financingTotalData.getFormattedString())
        financialStatusView.setLeftSelected()
    }
}

final class ClassicSpacerColumn: UIView {
    
    private var classicColumn: ClassicGradientColumn?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let column = ClassicGradientColumn()
        column.translatesAutoresizingMaskIntoConstraints = false
        addSubview(column)
        column.topAnchor.constraint(equalTo: topAnchor).isActive = true
        column.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        column.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        column.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.classicColumn = column
        column.setBottomText(nil)
        column.setBarHeight(0, contentHeight: 0)
        column.setTopText(nil)
        classicColumn?.setBaseLineColor(.clear)
    }
    
    func setBaseLineColor(_ color: UIColor) {
        self.classicColumn?.setBaseLineColor(color)
    }
}

extension ClassicBarView: AccessibilityCapable { }
