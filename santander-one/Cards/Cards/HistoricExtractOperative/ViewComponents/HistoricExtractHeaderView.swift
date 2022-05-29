//
//  HistoricExtractHeaderView.swift
//  Cards
//
//  Created by Ignacio González Miró on 17/11/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol HistoricExtractHeaderDelegate: AnyObject {
    func didTapInShopMap()
    func didTapInPdfExtract()
}

final class HistoricExtractHeaderView: UIDesignableView {
    @IBOutlet private weak var headerStackView: UIStackView!
    
    weak var delegate: HistoricExtractHeaderDelegate?

    private var singleCardHeaderView: SingleCardHeaderView?

    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }

    func configure(_ viewModel: NextSettlementViewModel, isMapEnabled: Bool, isExtractPdfEnabled: Bool) {
        self.setSingleHeaderView(viewModel)
        self.addSeparatorView()
        self.setChargeDateView(viewModel)
        self.setPaymentTypeView(viewModel)
        self.setButtonActionsView(viewModel, isMapEnabled: isMapEnabled, isExtractPdfEnabled: isExtractPdfEnabled)
    }
    
    func updateHeaderView(_ viewModel: NextSettlementViewModel) {
        singleCardHeaderView?.setInfo(viewModel)
    }
}

private extension HistoricExtractHeaderView {
    func setupView() {
        self.backgroundColor = .skyGray
    }
    
    // MARK: Items in StackView
    func setSingleHeaderView(_ viewModel: NextSettlementViewModel) {
        singleCardHeaderView = SingleCardHeaderView()
        guard let singleCardHeaderView = singleCardHeaderView else { return }
        singleCardHeaderView.setInfo(viewModel)
        self.headerStackView.addArrangedSubview(singleCardHeaderView)
    }
    
    func setChargeDateView(_ viewModel: NextSettlementViewModel) {
        let chargeDateView = ChargeDateView()
        chargeDateView.setInfo(viewModel.chargeDateText)
        self.headerStackView.addArrangedSubview(chargeDateView)
    }
    
    func setPaymentTypeView(_ viewModel: NextSettlementViewModel) {
        guard let paymentTypeViewModel = viewModel.operationType else { return }
        addSeparatorView()
        let paymentTypeView = PaymentTypeView()
        paymentTypeView.setInfo(paymentTypeViewModel)
        self.headerStackView.addArrangedSubview(paymentTypeView)
    }
    
    func setButtonActionsView(_ viewModel: NextSettlementViewModel, isMapEnabled: Bool, isExtractPdfEnabled: Bool) {
        let actionButtonsView = HistoricExtractActionButtonsView()
        actionButtonsView.delegate = self
        isMapEnabled ? actionButtonsView.enableShoppingMapPill() : actionButtonsView.disableShoppingMapPill()
        isExtractPdfEnabled ? actionButtonsView.enableExtractPdfPill() : actionButtonsView.disableExtractPdfPill()
        self.headerStackView.addArrangedSubview(actionButtonsView)
    }
    
    func addSeparatorView() {
        let separatorView = DashedLineView()
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separatorView.backgroundColor = .clear
        self.headerStackView.addArrangedSubview(separatorView)
    }
}

extension HistoricExtractHeaderView: DidSelectInActionButtonsDelegate {
    func didTapInShopMap() {
        delegate?.didTapInShopMap()
    }
    
    func didTapInPdfExtract() {
        delegate?.didTapInPdfExtract()
    }
}
