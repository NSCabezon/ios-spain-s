import UIKit
import UI

public final class CardSubscriptionDetailGraphDetailStack: XibView {

    @IBOutlet private weak var stackView: UIStackView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ model: [CardSubscriptionDetailSummaryViewModel]) {
        model.forEach { modelByYear in
            addDetailView(modelByYear)
        }
    }
}
 
private extension CardSubscriptionDetailGraphDetailStack {
    func setupView() {
        stackView.backgroundColor = .mediumSkyGray
    }
    
    func addDetailView(_ model: CardSubscriptionDetailSummaryViewModel) {
        let detailView = CardSubscriptionDetailGraphDetailItemView()
        detailView.backgroundColor = .clear
        detailView.widthAnchor.constraint(equalToConstant: (layer.bounds.height - 1)/2).isActive = true
        detailView.configView(model)
        stackView.addArrangedSubview(detailView)
    }
}
