//
//  DualBarGraph.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 18/05/2020.
//

import UI
import CoreFoundationLib

protocol DualBarGraphDelegate: AnyObject {
    func didTapGraphBar(_ bar: DualBarGraph)
}

class DualBarGraph: UIDesignableView {
    
    @IBOutlet weak private var incomeGraph: UIView!
    @IBOutlet weak private var expenseGraph: UIView!
    @IBOutlet weak private var expenseGraphPredictive: UIView!
    @IBOutlet weak private var incomeGraphHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var expenseGraphHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var expenseGraphPredictivelHeightConstraint: NSLayoutConstraint!
    public weak var delegate: DualBarGraphDelegate?
    private var viewModel: DualGraphViewModel? {
        didSet {
            updateGraph()
        }
    }
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override func draw(_ rect: CGRect) {
        applyBarsStyle()
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupViews()
    }
    
    public func setViewModel(_ viewModel: DualGraphViewModel) {
        self.viewModel = viewModel
    }
}

private extension DualBarGraph {
    func setupViews() {
        self.accessibilityIdentifier = AccessibilityAnalysisArea.dualBarGraph.rawValue
        self.isUserInteractionEnabled = true
        expenseGraph.backgroundColor = .redGraphic
        expenseGraphPredictive.backgroundColor = UIColor.redGraphic.withAlphaComponent(0.3)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didReceiveTap(_:)))
        self.addGestureRecognizer(tapGesture)
        self.setIdentifiers()
    }
    
    func updateGraph() {
        guard let optionalViewModel = viewModel else {
            return
        }
        switch optionalViewModel.disabledGraph {
        case .expense:
            expenseGraph.isHidden = true
        case .income:
            incomeGraph.isHidden = true
        case .predictive:
            expenseGraphPredictive.isHidden = true
        case .none:
            break
        }
        incomeGraphHeightConstraint.constant = optionalViewModel.getMaxHeightForBarType(.income)
        expenseGraphHeightConstraint.constant = optionalViewModel.getMaxHeightForBarType(.expense)
        expenseGraphPredictivelHeightConstraint.constant = optionalViewModel.getMaxHeightForBarType(.predictive)
    }
    
    func applyBarsStyle() {
        self.incomeGraph.layer.sublayers?.removeAll()
        self.incomeGraph.applyGradientBackground(colors: [.lightGrayBlue, .paleBlue])
        self.incomeGraph.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
        self.expenseGraph.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
        self.expenseGraphPredictive.roundCorners(corners: [.topLeft, .topRight], radius: 5.0)
    }
    
    func setIdentifiers() {
        self.incomeGraph.accessibilityIdentifier = AccessibilityAnalysisSegment.incomeGraph.rawValue
        self.expenseGraph.accessibilityIdentifier = AccessibilityAnalysisSegment.expenseGraph.rawValue
        self.expenseGraphPredictive.accessibilityIdentifier = AccessibilityAnalysisSegment.predictiveExpenseGraph.rawValue
    }
    
    @objc func didReceiveTap(_ sender: UITapGestureRecognizer) {
        delegate?.didTapGraphBar(self)
    }
}
