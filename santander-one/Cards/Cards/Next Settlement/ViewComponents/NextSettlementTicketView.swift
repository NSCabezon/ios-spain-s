//
//  NextSettlementTicketView.swift
//  Cards
//
//  Created by Laura González on 06/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

final class NextSettlementTicketView: UIDesignableView {
    
    @IBOutlet private weak var containerView: BittenFrameView!
    @IBOutlet private weak var ticketStackView: UIStackView!
    @IBOutlet private weak var footerImage: UIImageView!
    
    var ticketContainerView: BittenFrameView {
        return containerView
    }
    var cardSelector: CardSelectorWithImageAndTitle?
    private var selectedCardPosition: Int?
    private var movementsView: LastMovementsView?
    private var biteCenterSingleCard: CGFloat = 140.0
    private var biteCenterMultipleCard: CGFloat = 120.0
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
    }
    
    func setViewModel(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: (LastMovementsViewDelegate & DidTapInCardsSegmentedDelegate & DidTapInCardPickerSelectorDelegate)?) {
        switch viewModel.getNumberOfCards() {
        case .one:
            addSingleCardViewStyle(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
        case .two:
            addTwoCardsViewStyle(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
        case .more:
            addMoreCardsViewStyle(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
        }
    }
    
    func reloadViewModel(_ configuration: NextSettlementViewModel) {
        reloadTwoCards(configuration)
    }
}

private extension NextSettlementTicketView {
    func setupView() {
        self.backgroundColor = .skyGray
        containerView.backgroundColor = .clear
        footerImage.isHidden = true
        footerImage.image = Assets.image(named: "areaTarjetaInfo")
        self.containerView.drawShadow(offset: (x: 0, y: 5), opacity: 0.5, color: .lightGray, radius: 6.0)
    }
    
    func addSingleCardViewStyle(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: LastMovementsViewDelegate?) {
        footerImage.isHidden = false
        containerView.biteCenterY = biteCenterSingleCard
        setSingleHeaderView(viewModel)
        addSeparatorView()
        setChargeDateView(viewModel)
        setPaymentTypeView(viewModel)
        setSingleCardMovements(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
    }
    
    func addTwoCardsViewStyle(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: (LastMovementsViewDelegate & DidTapInCardsSegmentedDelegate)?) {
        footerImage.isHidden = false
        containerView.biteCenterY = biteCenterMultipleCard
        setMultipleHeaderView(viewModel)
        addSeparatorView()
        setChargeDateView(viewModel)
        setPaymentTypeView(viewModel)
        addSeparatorView()
        setCardSegmentedView(viewModel, delegate: lastMovementsViewDelegate)
        setMultipleCardMovements(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
    }
    
    func addMoreCardsViewStyle(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: (LastMovementsViewDelegate & DidTapInCardPickerSelectorDelegate)?) {
        footerImage.isHidden = false
        containerView.biteCenterY = biteCenterMultipleCard
        setMultipleHeaderView(viewModel)
        addSeparatorView()
        setChargeDateView(viewModel)
        setPaymentTypeView(viewModel)
        addSeparatorView()
        setCardSelector(viewModel, delegate: lastMovementsViewDelegate)
        setMultipleCardMovements(viewModel, lastMovementsViewDelegate: lastMovementsViewDelegate)
    }

    func setSingleHeaderView(_ viewModel: NextSettlementViewModel) {
        let singleCardHeaderView = SingleCardHeaderView()
        singleCardHeaderView.setInfo(viewModel)
        self.ticketStackView.addArrangedSubview(singleCardHeaderView)
    }
    
    func setMultipleHeaderView(_ viewModel: NextSettlementViewModel) {
        let multipleCardHeaderView = MultipleCardHeaderView()
        multipleCardHeaderView.setInfo(viewModel)
        self.ticketStackView.addArrangedSubview(multipleCardHeaderView)
    }

    func setChargeDateView(_ viewModel: NextSettlementViewModel) {
        let chargeDateView = ChargeDateView()
        chargeDateView.setInfo(viewModel.chargeDateText)
        self.ticketStackView.addArrangedSubview(chargeDateView)
    }
    
    func setPaymentTypeView(_ viewModel: NextSettlementViewModel) {
        guard let paymentTypeViewModel = viewModel.operationType else { return }
        addSeparatorView()
        let paymentTypeView = PaymentTypeView()
        paymentTypeView.setInfo(paymentTypeViewModel)
        self.ticketStackView.addArrangedSubview(paymentTypeView)
    }
    
    func setCardSegmentedView(_ viewModel: NextSettlementViewModel, delegate: DidTapInCardsSegmentedDelegate?) {
        let segmentedView = LisboaSegmentedWithImageAndTitle()
        let orderButtons = viewModel.getOrderButtons()
        let primaryButton = viewModel.getCurrentCardSelected(orderButtons.principal)
        let secondaryButton = viewModel.getCurrentCardSelected(orderButtons.secondary)
        segmentedView.setInfo(primaryButton?.text ?? "", rightCardName: secondaryButton?.text ?? "", ownerCardUrl: primaryButton?.urlString ?? "", associatedCardUrl: secondaryButton?.urlString ?? "")
        if viewModel.isOrderButtonsReversed() {
            segmentedView.setSecondarySegmentedSelected()
        }
        segmentedView.delegate = delegate
        self.ticketStackView.addArrangedSubview(segmentedView)
    }
    
    func addSeparatorView() {
        let separatorView = DashedLineView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = .clear
        self.ticketStackView.addArrangedSubview(separatorView)
    }
    
    func addSimpleSeparatorView() {
        let separatorView = UIView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.ticketStackView.addArrangedSubview(separatorView)
        separatorView.leadingAnchor.constraint(equalTo: ticketStackView.leadingAnchor, constant: 10).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: ticketStackView.trailingAnchor, constant: -10).isActive = true
        separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setSingleCardMovements(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: LastMovementsViewDelegate?) {
        guard
            let titularMovements = viewModel.getMovementWithPan?.movements,
            !titularMovements.isEmpty
            else {
                let emptyView = EmptyMovementsView()
                addSeparatorView()
                self.ticketStackView.addArrangedSubview(emptyView)
                return
        }
        let movementsView = LastMovementsView()
        movementsView.delegate = lastMovementsViewDelegate
        movementsView.setSingleCardStyle(titularMovements)
        addSeparatorView()
        self.ticketStackView.addArrangedSubview(movementsView)
    }
    
    func setMultipleCardMovements(_ viewModel: NextSettlementViewModel, lastMovementsViewDelegate: LastMovementsViewDelegate?) {
        movementsView = LastMovementsView()
        guard let movementsView = movementsView else { return }
        guard
            let titularMovements = viewModel.getMovementWithPan?.movements,
            !titularMovements.isEmpty
            else {
                movementsView.setMultipleCardEmptyViewStyle()
                self.addSimpleSeparatorView()
                self.ticketStackView.addArrangedSubview(movementsView)
                self.addSimpleSeparatorView()
                self.addEmptyView()
                return
        }
        movementsView.delegate = lastMovementsViewDelegate
        movementsView.setMultipleCardStyle(titularMovements)
        addSimpleSeparatorView()
        self.ticketStackView.addArrangedSubview(movementsView)
    }
    
    func addEmptyView() {
        let emptyView = EmptyMovementsView()
        emptyView.modifyConstraints()
        self.ticketStackView.addArrangedSubview(emptyView)
    }
    
    func reloadTwoCards(_ viewModel: NextSettlementViewModel) {
        guard let titularMovements = viewModel.getMovementWithPan?.movements, !titularMovements.isEmpty else { return }
        movementsView?.setTotalAmount(titularMovements)
    }
    
    func setCardSelector(_ viewModel: NextSettlementViewModel, delegate: DidTapInCardPickerSelectorDelegate?) {
        guard let card = viewModel.getCurrentCardSelected(viewModel.cardEntity.formattedPAN ?? ""),
            let ownerCards = viewModel.ownerCards else {
                return
        }
        let cardSelector = CardSelectorWithImageAndTitle()
        cardSelector.delegate = delegate
        self.selectedCardPosition = card.position
        cardSelector.configCardSelector(card, numberOfCards: ownerCards.count.description, isCollapsed: true)
        self.cardSelector = cardSelector
        self.ticketStackView.addArrangedSubview(cardSelector)
    }
}

extension NextSettlementTicketView: LastMovementsViewDelegate {
    func didMoreMovementsSelected() {}
}
