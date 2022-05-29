//
//  CardListFinanceableTransactionTableViewCell.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import UIKit
import UI
import CoreFoundationLib

protocol CardListFinanceableTransactionCellDelegate: AnyObject {
    func loadEasyPay(for viewModel: CardListFinanceableTransactionViewModel)
    func didSelectCell(_ cell: CardListFinanceableTransactionTableViewCell)
    func didSelectTransaction(_ viewModel: CardListFinanceableTransactionViewModel)
}

class CardListFinanceableTransactionTableViewCell: UITableViewCell {
    static let identifier = "CardListFinanceableTransactionTableViewCell"
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var seeFractionableOptionsView: SeeFractionableOptionsView!
    @IBOutlet private weak var pointLineDivider: PointLine!
    @IBOutlet private weak var dividerView: UIView!
   
    private var viewModel: CardListFinanceableTransactionViewModel?
    private weak var delegate: CardListFinanceableTransactionCellDelegate?
    private let duration = 0.2
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.seeFractionableOptionsView.configView(false, feeViewModels: [])
    }
    
    func setDelegate(_ delegate: CardListFinanceableTransactionCellDelegate?) {
        self.delegate = delegate
    }
    
    func setViewModel(_ viewModel: CardListFinanceableTransactionViewModel) {
        self.viewModel = viewModel
        self.descriptionLabel.text = viewModel.title
        let amountAttributedText = self.amountAttributedText(viewModel)
        self.amountLabel.attributedText = amountAttributedText
        self.setFractionableOptionsView(viewModel)
    }
    
    func updateSeparators(_ isLastCell: Bool) {
        self.pointLineDivider.isHidden = isLastCell
        self.dividerView.isHidden = !isLastCell
    }
    
    func collapseExpandAnimation(duration: TimeInterval, completion: @escaping () -> Void) {
        guard let viewModel = self.viewModel else { return }
         UIView.animateKeyframes(
             withDuration: duration,
             delay: 0,
             options: .calculationModePaced,
             animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.seeFractionableOptionsView.configView(viewModel.isExpanded, feeViewModels: viewModel.feeViewModels)
             },
             completion: { (finished) in
                guard finished else { return }
                completion()
         })
    }
}

private extension CardListFinanceableTransactionTableViewCell {
    func setFractionableOptionsView(_ viewModel: CardListFinanceableTransactionViewModel) {
        self.seeFractionableOptionsView.delegate = self
        self.seeFractionableOptionsView.configView(viewModel.isExpanded, feeViewModels: viewModel.feeViewModels)
    }
    
    func amountAttributedText(_ viewModel: CardListFinanceableTransactionViewModel) -> NSAttributedString? {
        guard let amount = viewModel.amount else {
            return nil
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 16)
        return decorator.getFormatedCurrency()
    }
}

extension CardListFinanceableTransactionTableViewCell: DidTapInSeeFractionableOptionsViewDelegate {
    func didTapInSelector() {
        self.viewModel?.toggle()
        self.delegate?.didSelectCell(self)
        guard let viewModel = self.viewModel else { return }
        guard !viewModel.isEasyPayLoaded() else { return }
        self.delegate?.loadEasyPay(for: viewModel)
    }
}
