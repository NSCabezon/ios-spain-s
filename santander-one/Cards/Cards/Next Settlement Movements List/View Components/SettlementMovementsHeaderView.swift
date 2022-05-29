//
//  SettlementMovementsHeaderView.swift
//  Cards
//
//  Created by David Gálvez Alonso on 15/10/2020.
//

import UI

final class SettlementMovementsHeaderView: UIDesignableView {
    
    @IBOutlet private weak var singleCardHeaderView: SingleCardHeaderView!
    @IBOutlet private weak var chargeDateView: ChargeDateView!
    @IBOutlet private weak var paymentTypeView: PaymentTypeView!
    @IBOutlet private weak var actionButtonView: NextSettlementActionView!
    @IBOutlet private var separatorViews: [UIView]!
    @IBOutlet private weak var hiddenStackView: UIStackView!
    @IBOutlet private weak var multipleCardHeaderView: MultipleCardHeaderView!
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
    }
    
    public func addCardViewStyle(_ viewModel: NextSettlementViewModel) {
        if viewModel.getNumberOfCards() == .one {
            singleCardHeaderView.setInfo(viewModel)
            singleCardHeaderView.isHidden = false
        } else {
            multipleCardHeaderView.setInfo(viewModel)
            multipleCardHeaderView.isHidden = false
        }
        chargeDateView.setInfo(viewModel.chargeDateText)
        guard let paymentTypeViewModel = viewModel.operationType else {
            paymentTypeView.isHidden = true
            return
        }
        paymentTypeView.setInfo(paymentTypeViewModel)
    }
    
    public func setActions(_ viewModels: [NextSettlementActionViewModel]) {
        actionButtonView.setActions(viewModels)
    }
    
    public func getMaxScroll() -> CGFloat {
        return hiddenStackView.frame.height
    }
}

private extension SettlementMovementsHeaderView {
    func setupView() {
        self.backgroundColor = .skyGray
        singleCardHeaderView.backgroundColor = .clear
        multipleCardHeaderView.backgroundColor = .clear
        chargeDateView.backgroundColor = .clear
        actionButtonView.backgroundColor = .clear
        separatorViews.forEach { $0.backgroundColor = .mediumSkyGray}
        self.addShadow(location: .bottom, color: .brownGray, opacity: 0, height: 1)
    }
}
