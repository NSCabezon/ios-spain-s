import Foundation
import CoreFoundationLib

enum PGActionType {
    case limit, graph, none
}

class ExpensesCarouselItem: CarouselClassicItemViewModelType {

    private weak var containerView: ClassicBarView?
    private lazy var graphView: ClassicBarView = {
        let view = ClassicBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onSetLimits = { [weak self] in
            self?.action?(.limit)
        }
        view.onTapGraph = { [weak self] in
            self?.action?(.graph)
        }
        
        return view
    }()    
    var view: UIView {
        return graphView
    }
    var requiredHeight: CGFloat = 180
    var action: ((PGActionType) -> Void)?
    var blurred: Bool = false
    
    func setExpenses(_ bars: [ExpensesBarInfo], budgetSize: Float, predictiveExpense: Decimal?, predictiveExpenseSize: Float?, animated: Bool, isBigWhatsNewBubble: Bool) {
        var result = [ExpensesBarInfo]()
        for bar in bars {
            let column = ExpensesBarInfo(topTitle: bar.topTitle, barSize: bar.barSize, bottomTitle: bar.bottomTitle, blurred: blurred, monthInfo: bar.monthInfo)
            result.append(column)
        }
        graphView.setBarData(result, budgetSize: budgetSize, predictiveExpense: predictiveExpense, predictiveExpenseSize: predictiveExpenseSize)
        graphView.show(animated, isBigWhatsNewBubble: isBigWhatsNewBubble)
    }
    
    func show(_ animated: Bool, isBigWhatsNewBubble: Bool) {
        containerView?.show(animated, isBigWhatsNewBubble: isBigWhatsNewBubble)
    }
    
    func viewWillAppear() {
        graphView.viewWillAppear()
    }
    
    func setDiscreteMode(_ enabled: Bool) { graphView.setDiscreteMode(enabled) }

    func setFinantialStatusInfo(totalBalance: AmountEntity?, financingTotal: AmountEntity?, tooltipText: String) {
        graphView.setFinantialStatusInfo(totalBalance: totalBalance, financingTotal: financingTotal, tooltipText: tooltipText)
    }
    
    func showEditBudgetView(editBudget: EditBudgetEntity, delegate: BudgetBubbleViewProtocol?) {
        graphView.showEditBudgetView(editBudget: editBudget, delegate: delegate)
    }
}
