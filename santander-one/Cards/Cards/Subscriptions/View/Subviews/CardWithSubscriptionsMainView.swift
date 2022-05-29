//
//  CardWithSubscriptionsMainView.swift
//  Cards
//
//  Created by Ignacio González Miró on 11/5/21.
//

import Foundation
import UI

protocol CardWithSubscriptionsMainViewDelegate: AnyObject {
    func didTapInDetail(_ viewModel: CardSubscriptionViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel)
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel)
}

public final class CardWithSubscriptionsMainView: XibView {
    @IBOutlet private weak var containerStackView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: CardWithSubscriptionsMainViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        containerStackView.drawBorder(cornerRadius: 4, color: .lightSkyBlue, width: 1)
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel, type: CardSubscriptionSeeMoreType) {
        addSubscriptionPill(viewModel, type: type, fromViewType: .card)
    }
    
    func configView(_ viewModels: [CardSubscriptionViewModel], type: CardSubscriptionSeeMoreType, numOfActiveShops: Int) {
        viewModels.enumerated().forEach { (index, viewModel) in
            if viewModel.isActive, index == 0 {
                addCardHeader(viewModel, numOfActiveShops: numOfActiveShops)
            }
            addSubscriptionPill(viewModel, type: type, fromViewType: .card)
        }
    }
}

private extension CardWithSubscriptionsMainView {
    func setupView() {
        backgroundColor = .clear
        containerStackView.backgroundColor = .skyGray
        stackView.spacing = 12
    }
    
    func addSubscriptionPill(_ viewModel: CardSubscriptionViewModel, type: CardSubscriptionSeeMoreType, fromViewType: ShowCardSubscriprionFromView) {
        let view = SubscriptionMovementView()
        view.delegate = self
        view.configView(viewModel, type: type, fromViewType: fromViewType)
        stackView.addArrangedSubview(view)
    }
    
    func addCardHeader(_ viewModel: CardSubscriptionViewModel, numOfActiveShops: Int) {
        let view = CardHeaderView()
        view.configView(viewModel, numOfActiveShops: numOfActiveShops)
        view.heightAnchor.constraint(equalToConstant: 64).isActive = true
        stackView.addArrangedSubview(view)
    }
}

extension CardWithSubscriptionsMainView: SubscriptionMovementViewDelegate {
    func didTapInDetail(_ viewModel: CardSubscriptionViewModel) {
        delegate?.didTapInDetail(viewModel)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel) {
        delegate?.didSelectSeeFrationateOptions(viewModel)
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel) {
        delegate?.didTapInSubscriptionSwitch(isOn, viewModel: viewModel)
    }
}
