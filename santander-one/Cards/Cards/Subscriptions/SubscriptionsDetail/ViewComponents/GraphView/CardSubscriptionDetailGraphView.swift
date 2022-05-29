import UIKit
import UI

public final class CardSubscriptionDetailGraphView: XibView {

    @IBOutlet private weak var verticalStackView: UIStackView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configView(_ viewModel: CardSubscriptionDetailGraphViewModel?, type: CardSubscriptionGraphType) {
        self.removeArrangedSubviewsIfNeeded()
        switch type {
        case .empty:
            guard let yearViewModel = viewModel?.yearViewModel else { return }
            addGraphView(yearViewModel, type: type)
        case .graph:
            guard let model = viewModel,
                  let yearViewModel = model.yearViewModel,
                  let summaryViewModel = model.summaryViewModel else {
                return
            }
            addGraphView(yearViewModel, type: type)
            addSeparatorView()
            addGraphDetailView(summaryViewModel)
        }
    }
}
    
private extension CardSubscriptionDetailGraphView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func addGraphView(_ model: [CardSubscriptionDetailYearViewModel], type: CardSubscriptionGraphType) {
        let graphView = CardSubscriptionDetailGraphCollectionView()
        graphView.configView(model, type: type)
        graphView.heightAnchor.constraint(equalToConstant: 236).isActive = true
        verticalStackView.addArrangedSubview(graphView)
    }
    
    func addSeparatorView() {
        let separatorView = SeparatorView()
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        verticalStackView.addArrangedSubview(separatorView)
    }
    
    func addGraphDetailView(_ model: [CardSubscriptionDetailSummaryViewModel]) {
        let detailView = CardSubscriptionDetailGraphDetailStack()
        detailView.heightAnchor.constraint(equalToConstant: 166).isActive = true
        detailView.configView(model)
        verticalStackView.addArrangedSubview(detailView)
    }
    
    func removeArrangedSubviewsIfNeeded() {
        if !self.verticalStackView.arrangedSubviews.isEmpty {
            self.verticalStackView.removeAllArrangedSubviews()
        }
    }
}
