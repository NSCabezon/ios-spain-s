//
//  CardTransactionCollectionViewCell.swift
//  Pods
//
//  Created by Hernán Villamil on 7/4/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import UI

public enum CardTransactionCollectionViewCellState: State {
    case idle
    case item(CardTransactionViewItemRepresentable)
    case timeManager(TimeManager)
}

final class CardTransactionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    private var item: CardTransactionViewItemRepresentable?
    private let detailsView = CardTransactionCollectionDetailsView()
    private let infoView = CardTransactionCollectionInfoView()
    let bannerView = CardTransactionCollectionBannerView()
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.backgroundColor = .white
        view.setSpacing(0)
        view.setup(with: self.containerView)
        return view
    }()
    private var subscriptions = Set<AnyCancellable>()
    lazy var state: AnyPublisher<CardTransactionCollectionViewCellState, Never> = {
        stateSubject.eraseToAnyPublisher()
    }()
    public let stateSubject = PassthroughSubject<CardTransactionCollectionViewCellState, Never>()
    var width: CGFloat {
        return UIScreen.main.bounds.size.width * 0.80
    }
    var didSelectOffer: ((CardTransactionViewItemRepresentable?) -> Void)?
    var didSelectFractionate: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideLoadingIfNeeded()
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hideFractionateButtonIfNeeded()
    }
}

private extension CardTransactionCollectionViewCell {
    func bind() {
        bindItem()
        bindActions()
        bindTimeManger()
    }
    
    func bindItem() {
        state
            .case(CardTransactionCollectionViewCellState.item)
            .compactMap { $0 }
            .assign(to: \.item, on: detailsView)
            .store(in: &subscriptions)
        state
            .case(CardTransactionCollectionViewCellState.item)
            .compactMap { $0 }
            .assign(to: \.item, on: infoView)
            .store(in: &subscriptions)
        state
            .case(CardTransactionCollectionViewCellState.item)
            .compactMap { $0 }
            .assign(to: \.item, on: bannerView)
            .store(in: &subscriptions)
        state
            .case(CardTransactionCollectionViewCellState.item)
            .sink { [unowned self] item in
                self.item = item
                scrollableStackView.addArrangedSubview(detailsView)
                scrollableStackView.addArrangedSubview(infoView)
                guard item.offerRepresentable?.bannerRepresentable != nil else { return }
                scrollableStackView.addArrangedSubview(bannerView)
            }.store(in: &subscriptions)
    }
    
    func bindActions() {
        bannerView.didSelectOfferSubject
            .sink { [unowned self] item in
                self.didSelectOffer?(item)
            }.store(in: &subscriptions)
        
        detailsView.didSelecFractionatedSubject
            .sink { [unowned self] _ in
                self.didSelectFractionate?()
            }.store(in: &subscriptions)
    }
    
    func bindTimeManger() {
        state
            .case(CardTransactionCollectionViewCellState.timeManager)
            .compactMap { $0 }
            .assign(to: \.timeManager, on: infoView)
            .store(in: &subscriptions)
    }
}

private extension CardTransactionCollectionViewCell {
    func hideLoadingIfNeeded() {
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? CardTransactionCollectionBannerView {
                view.hideLoading()
            }
        }
    }
    
    func hideFractionateButtonIfNeeded() {
        scrollableStackView.getArrangedSubviews().forEach {
            if let view = $0 as? CardTransactionCollectionDetailsView {
                view.hideFractionateButton()
            }
        }
    }
}

extension CardTransactionCollectionViewCell: CarrouselCollectionRezisableCell {}
