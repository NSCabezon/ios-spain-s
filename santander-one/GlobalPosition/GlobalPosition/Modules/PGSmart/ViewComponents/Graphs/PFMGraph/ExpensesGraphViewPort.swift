//
//  ExpensesViewPort.swift
//  Grafica
//
//  Created by Boris Chirino Fernandez on 19/12/2019.
//  Copyright © 2019 Boris Chirino Fernandez. All rights reserved.
//

import UI
import CoreFoundationLib

/// Points of the three graphic circles used to draw the curves at both sides of the graph.
struct DataForLeadingTrailingCurves {
    var leftPoint: CGPoint
    var middlePoint: CGPoint
    var rightPoint: CGPoint
}

/// forward UI actions on the graph
protocol ExpensesGraphViewPortActionsDelegate: AnyObject {
    func didTapOnEditBudget(originView: UIView)
    func didTapOnAnalysis()
}

/// behaviours of the viewport wich contain the drawing board.
protocol ExpensesGraphViewPortConformable: DiscreteModeConformable {
    /// setting the model cause the graph to be illustrated and the loading view dissappear
    /// - Parameter model: the data itself needed to draw the curves
    func setModel(_ model: ExpensesGraphViewModel)
    /// Draw the initial and ending curves of the graph, wich by definition are fakes, both are used to beautify the graph
    /// - Parameter points: see DataForLeadingTrailingCurves structure
    func addOutsideLines(points: DataForLeadingTrailingCurves)
}

class ExpensesGraphViewPort: DesignableView {
    @IBOutlet private weak var monthsBar: UIView?
    @IBOutlet private weak var monthsBackgroundBar: UIView?
    @IBOutlet private weak var leftMonthLbl: UILabel?
    @IBOutlet private weak var middleMonthLbl: UILabel?
    @IBOutlet private weak var rightMonthLbl: UILabel?
    @IBOutlet private weak var loadingView: UIImageView?
    @IBOutlet private weak var drawingBoard: DrawingBoardView?
    @IBOutlet private weak var containerDrawingBoard: UIView!
    @IBOutlet private weak var topChartConstraint: NSLayoutConstraint!
    
    private var expensesButton: VerticalExpenseInfoView?
    private let controlPointDelta: CGFloat = 15.0
    var dashLine = DashLineButton(style: .smart)
    var discreteMode: Bool = false
    var leadingTrailingCurves: DataForLeadingTrailingCurves?
    
    private var circlesViews: [UIView]?
    private var didTapIndex: Int?
    private var dashLineCenterConstraint: NSLayoutConstraint?
    
    private var model: ExpensesGraphViewModel? {
        didSet {
            self.discreteMode = model?.isDiscreteMode ?? false
            self.illustrateExpenses()
            self.setDashLinePosition()
        }
    }
    weak var actionsDelegate: ExpensesGraphViewPortActionsDelegate?
    var onTapGraph: (() -> Void)?
    
    override func commonInit() {
        super.commonInit()
        self.translatesAutoresizingMaskIntoConstraints = false
        drawingBoard?.viewPort = self
        drawingBoard?.delegate = self
        monthsBackgroundBar?.layer.cornerRadius = 6.0
        loadingView?.setSecondaryLoader(tintColor: .white)
        let leftMonthTap = UITapGestureRecognizer(target: self, action: #selector(handleMonthsTap(_:)))
        let middleMonthTap = UITapGestureRecognizer(target: self, action: #selector(handleMonthsTap(_:)))
        let rightMonthTap = UITapGestureRecognizer(target: self, action: #selector(handleMonthsTap(_:)))
        
        leftMonthLbl?.addGestureRecognizer(leftMonthTap)
        leftMonthLbl?.tag = 0
        middleMonthLbl?.addGestureRecognizer(middleMonthTap)
        middleMonthLbl?.tag = 1
        rightMonthLbl?.addGestureRecognizer(rightMonthTap)
        rightMonthLbl?.tag = 2
        expensesButton = VerticalExpenseInfoView()
        expensesButton?.translatesAutoresizingMaskIntoConstraints = false
        expensesButton?.containerView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        expensesButton?.containerView.addGestureRecognizer(tap)
        dashLine.translatesAutoresizingMaskIntoConstraints = false
        dashLine.isHidden = true
        self.addSubview(dashLine)
        
        dashLine.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        dashLine.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        if let drawingBottomAnchor = drawingBoard?.bottomAnchor {
            dashLineCenterConstraint = dashLine.centerYAnchor.constraint(equalTo: drawingBottomAnchor)
        }
        dashLineCenterConstraint?.isActive = true
        setAccessibilityIdentifier()
    }
    
    override func draw(_ rect: CGRect) {
        guard let optModel = self.model?.parsedResults?.expenses, let curvesData = self.leadingTrailingCurves else { return }
        let path = UIBezierPath()
        UIColor.white.setStroke()
        path.move(to: curvesData.leftPoint)
        
        // Draw initial and ending fakes curves
        // leftCurve
        var cpDelta: CGFloat = 0.0
        let firstPointCoordForY = curvesData.leftPoint.y
        let leftEndPoint = CGPoint(x: 0, y: firstPointCoordForY)
        
        var midpoint = midPointForPoints(firstPoint: curvesData.leftPoint, secondPoint: leftEndPoint)
        if  optModel[0].amount < optModel[1].amount {
            cpDelta = midpoint.y + controlPointDelta
        } else if optModel[0].amount > optModel[1].amount {
            cpDelta = midpoint.y - controlPointDelta
        } else {
            cpDelta = leftEndPoint.y
        }
        var midpointDelta: CGPoint = CGPoint(x: midpoint.x, y: cpDelta)
        path.addQuadCurve(to: leftEndPoint, controlPoint: midpointDelta)
        
        // right curve
        path.move(to: curvesData.rightPoint)
        let lastPointCoordForY = curvesData.rightPoint.y
        let lastEndPoint = CGPoint(x: self.bounds.maxX, y: lastPointCoordForY)
        
        midpoint = midPointForPoints(firstPoint: curvesData.rightPoint, secondPoint: lastEndPoint)
        if optModel[1].amount < optModel[2].amount { // curve up
            cpDelta = midpoint.y - controlPointDelta
        } else if optModel[1].amount > optModel[2].amount { // curve down
            cpDelta = midpoint.y + controlPointDelta
        } else {
            cpDelta = lastEndPoint.y
        }
        midpointDelta = CGPoint(x: midpoint.x, y: cpDelta)
        path.addQuadCurve(to: lastEndPoint, controlPoint: midpointDelta)
        
        path.lineWidth = BoardAttributes.lineWidth
        path.stroke()
        
        // lines from points down to months
        // first line
        path.lineWidth = BoardAttributes.verticalLineWidth
        path.move(to: curvesData.leftPoint)
        if let centerFirstMonth = self.monthsBar?.convert(leftMonthLbl!.center, to: self) {
            path.addLine(to: CGPoint(x: centerFirstMonth.x, y: self.monthsBar!.frame.minY) )
        }
        
        // second line
        path.move(to: curvesData.middlePoint)
        if let centerMiddleMonth = self.monthsBar?.convert(middleMonthLbl!.center, to: self) {
            path.addLine(to: CGPoint(x: centerMiddleMonth.x, y: self.monthsBar!.frame.minY) )
        }
        
        // third line
        path.move(to: curvesData.rightPoint)
        if let rightMonth = self.monthsBar?.convert(rightMonthLbl!.center, to: self) {
            path.addLine(to: CGPoint(x: rightMonth.x, y: self.monthsBar!.frame.minY))
        }
        
        path.stroke()
        
    }
    
    override func layoutSubviews() {
        self.monthsBar?.layer.cornerRadius = 7.0
    }
    
    deinit {
        self.model = nil
    }
    
    func showLoading() {
        loadingView?.setSecondaryLoader(tintColor: .white)
    }
    
    func stopLoading() {
        loadingView?.removeLoader()
    }
    
    @objc func buttonPressed() {
        self.onTapGraph?()
    }
}

// MARK: - ExpensesGraphViewPortConformable
extension ExpensesGraphViewPort: ExpensesGraphViewPortConformable {
    func addOutsideLines(points: DataForLeadingTrailingCurves) {
        leadingTrailingCurves = DataForLeadingTrailingCurves(leftPoint: points.leftPoint,
                                                             middlePoint: points.middlePoint,
                                                             rightPoint: points.rightPoint)
    }
    
    func setModel(_ model: ExpensesGraphViewModel) {
        self.model = model
        dashLine.buttonLabel.text = localized("pg_label_objective")
    }
}

// MARK: - Private functions
private extension ExpensesGraphViewPort {
    
    /// handle the expense button tap
    /// - Parameter sender: the gesture of the ui item
    @objc private func handleMonthsTap(_ sender: UITapGestureRecognizer) {
        guard  let monthIndex = sender.view?.tag else { return }
        guard let monthLabel = expensesButtonMeta(monthIndex).label, let item = expensesButtonMeta(monthIndex).item else { return }
        self.showButton(withData: item, label: monthLabel)
        UIAccessibility.post(notification: .screenChanged, argument: self.expensesButton)
        
        didTapIndex = monthIndex
    }
    
    /// Called once the data is passed to this instance causing the view draw all months, graphs and expenses button.
    func illustrateExpenses() {
        loadingView?.removeLoader()
        guard let optionalModel = self.model, optionalModel.parsedResults?.expenses.count == 3 else { return }
        guard let label = expensesButtonMeta(didTapIndex).label, let item = expensesButtonMeta(didTapIndex).item else { return }
        self.showButton(withData: item, label: label)
        
        leftMonthLbl?.text     = optionalModel.parsedResults?.expenses[0].upperCasedMonth()
        leftMonthLbl?.accessibilityLabel = optionalModel.parsedResults?.expenses[0].monthInfo
        middleMonthLbl?.text   = optionalModel.parsedResults?.expenses[1].upperCasedMonth()
        middleMonthLbl?.accessibilityLabel = optionalModel.parsedResults?.expenses[1].monthInfo
        rightMonthLbl?.text    = optionalModel.parsedResults?.expenses[2].upperCasedMonth()
        rightMonthLbl?.accessibilityLabel = optionalModel.parsedResults?.expenses[2].monthInfo
        monthsBar?.isHidden = false
        dashLine.isHidden = false
        monthsBackgroundBar?.isHidden = false
        drawingBoard?.setModel(optionalModel)
        drawingBoard?.setNeedsDisplay()
    }
    
    /// Display the expenses button
    /// - Parameters:
    ///   - data: the data of the selected month
    ///   - label: the label where the buttons should be used as centerY
    func showButton(withData data: MonthlyBalanceSmartPG, label: UILabel) {
        let existingView = self.subviews.filter { $0 is VerticalExpenseInfoView }
        if existingView.count > 0 {
            self.expensesButton?.removeFromSuperview()
            self.addSubview(self.expensesButton!)
        } else {
            self.addSubview(self.expensesButton!)
        }
        let centerX: NSLayoutXAxisAnchor = label.centerXAnchor
        self.expensesButton?.monthLabel.text = data.month.uppercased()
        self.expensesButton?.monthInfo = data.monthInfo
        self.expensesButton?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.expensesButton?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 7).isActive = true
        self.expensesButton?.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        self.expensesButton?.centerXAnchor.constraint(equalTo: centerX).isActive = true
        self.expensesButton?.setNeedsLayout()
        self.expensesButton?.amountLabel.text = data.formmatedMoneyText()?.string
        self.expensesButton?.amountLabel.isBlured = self.discreteMode
        self.setAccessibility(setViewAccessibility: self.setAccessibility)
    }
    
    /// Return on wich label place de button with the corresponding data.
    /// - Parameter forModelIndex: Specify an index for an element inside de expenses array. if no index is specified the current month will be used.
    func expensesButtonMeta(_ forModelIndex: Int? = nil) -> (label: UILabel?, item: MonthlyBalanceSmartPG?) {
        guard let optionalModel = self.model?.parsedResults?.expenses else { return (label: nil, item: nil)}
        
        let itemIndex = forModelIndex != nil ? forModelIndex :
            optionalModel.firstIndex(where: { (item) -> Bool in
                return item.upperCasedMonth() == self.model?.parsedResults?.currentMonth.uppercased()
            })
        
        var label: UILabel?
        switch itemIndex {
        case 0:
            label = leftMonthLbl
        case 1:
            label = middleMonthLbl
        case 2:
            label = rightMonthLbl
        default:()
        }
        
        guard let elementIndex = itemIndex else { return (label: nil, item: nil)}
        return (label, optionalModel[elementIndex])
    }
    
    func setDashLinePosition() {
        guard let model = model, let monthsBar = monthsBar else { return }
        
        /// Resize or not de chart in relation of budgetSize
        let minTopConstant: CGFloat = 20
        
        let maxContentSpace = monthsBar.frame.origin.y - 10 - minTopConstant
        let resizeConstantBudget = maxContentSpace - min(maxContentSpace/CGFloat(model.budgetSize), maxContentSpace)
        let newConstant = model.budgetSize > 1 ? resizeConstantBudget + minTopConstant : minTopConstant
        
        topChartConstraint.constant = min(newConstant, maxContentSpace)
        
        /// Set DashLine position in relation of budgetSize
        let maxDashLinePosition = maxContentSpace
        let minDashLinePosition: CGFloat = 0.0
        let dashHeightRelationBudget = maxContentSpace * CGFloat(model.budgetSize) + minDashLinePosition
        let dashLinePosition: CGFloat = model.budgetSize >= 1 ? maxDashLinePosition : dashHeightRelationBudget
        
        dashLineCenterConstraint?.constant = -max(minDashLinePosition, min(maxDashLinePosition, dashLinePosition))
        
        checkDashLineLabelPosition(dashLineCenterConstraint?.constant ?? 0.0, minDashLinePosition: minDashLinePosition, dashLineHeight: dashLine.tapView.frame.height)
    }
    
    func checkDashLineLabelPosition(_ position: CGFloat, minDashLinePosition: CGFloat, dashLineHeight: CGFloat) {
        guard let drawingBoard = drawingBoard,
              let monthsBar = monthsBar else { return }
        let bottomSpace = monthsBar.frame.origin.y - drawingBoard.frame.origin.y - drawingBoard.frame.height
        
        if -position <= minDashLinePosition + dashLineHeight/2 - bottomSpace {
            dashLine.moveLabelCenterPosition(dashLineHeight/2 + position + minDashLinePosition - bottomSpace)
        } else {
            dashLine.moveLabelCenterPosition(0.0)
        }
    }
    
    func setAccessibility() {
        self.contentView?.isAccessibilityElement = true
        self.contentView?.accessibilityLabel = localized("voiceover_expenseChart")
        self.contentView?.accessibilityTraits = .button
        self.leftMonthLbl?.isAccessibilityElement = !self.discreteMode
        self.middleMonthLbl?.isAccessibilityElement = !self.discreteMode
        self.rightMonthLbl?.isAccessibilityElement = !self.discreteMode
        self.expensesButton?.monthLabel.isAccessibilityElement = false
        self.expensesButton?.amountLabel.isAccessibilityElement = false
        self.expensesButton?.containerView.isAccessibilityElement = false
        self.expensesButton?.isAccessibilityElement = !self.discreteMode
        self.dashLine.isAccessibilityElement = true
        self.dashLine.buttonLabel.accessibilityLabel = localized("pg_label_objective")
        self.dashLine.buttonLabel.accessibilityTraits = .button
        self.setAccessibilityExpensesBtn()
        self.setOrderAccessibility()
    }
    
    func setAccessibilityExpensesBtn() {
        guard let month = self.expensesButton?.monthInfo,
              let amount = self.expensesButton?.amountLabel.text else { return }
        self.expensesButton?.accessibilityLabel = month + "\n" + amount
    }
    
    func setOrderAccessibility() {
        guard let expensesBtn = self.expensesButton,
              let dashBtn = self.dashLine.buttonLabel,
              let leftLbl = self.leftMonthLbl,
              let middleLbl = self.middleMonthLbl,
              let rightLbl = self.rightMonthLbl,
              let view = self.contentView else { return }
        self.accessibilityElements = [view as UIView, dashBtn as UIView,
                                      expensesBtn as UIView, leftLbl as UIView,
                                      middleLbl as UIView, rightLbl as UIView]
    }
    
    func setAccessibilityIdentifier() {
        self.accessibilityIdentifier = AccessibilityGlobalPosition.graphContainer
        self.expensesButton?.accessibilityIdentifier = AccessibilityGlobalPosition.verticalExpenseInfo
        self.dashLine.buttonLabel.restorationIdentifier = AccessibilityGlobalPosition.objetiveButton
        self.leftMonthLbl?.accessibilityIdentifier = AccessibilityGlobalPosition.leftMonth
        self.rightMonthLbl?.accessibilityIdentifier = AccessibilityGlobalPosition.rightMonth
        self.middleMonthLbl?.accessibilityIdentifier = AccessibilityGlobalPosition.middleMonth
        self.loadingView?.accessibilityIdentifier = AccessibilityGlobalPosition.graphLoadingView
    }
}

extension ExpensesGraphViewPort: DrawingBoardViewDelegate {
    
    func addTapCircleViews(points: [CGPoint]) {
        guard let drawingBoard = drawingBoard else { return }
        circlesViews?.forEach { $0.removeFromSuperview() }
        let size: CGFloat = 30.0
        points.enumerated().forEach { (point) in
            let tapView = UIView()
            tapView.frame.size = CGSize(width: size, height: size)
            tapView.center = drawingBoard.convert(point.element, to: self)
            tapView.isUserInteractionEnabled = true
            tapView.tag = point.offset
            tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMonthsTap(_:))))
            self.addSubview(tapView)
        }
    }
}

extension ExpensesGraphViewPort: AccessibilityCapable { }
