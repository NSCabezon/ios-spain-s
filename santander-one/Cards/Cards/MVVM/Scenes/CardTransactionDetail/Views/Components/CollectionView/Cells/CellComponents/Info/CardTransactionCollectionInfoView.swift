//
//  CardTransactionCollectionInfoView.swift
//  Pods
//
//  Created by Hernán Villamil on 7/4/22.
//

import CoreFoundationLib
import CoreDomain
import UIKit
import UI

final class CardTransactionCollectionInfoView: XibView {
    @IBOutlet private weak var detailsStackView: UIStackView!
    let verticalSpace: CGFloat = 20.0
    var item: CardTransactionViewItemRepresentable? {
        didSet { configureView(item) }
    }
    var timeManager: TimeManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func getHeight() -> CGFloat {
        let items = detailsStackView.arrangedSubviews.count
        let spacing = CGFloat(items - 1) * ExpandableConfig.detailSpacing
        
        return (CGFloat(items) * ExpandableConfig.stackViewItemHeight) + spacing + verticalSpace
    }
}

private extension CardTransactionCollectionInfoView {
    func setupView() {
        backgroundColor = .clear
    }
    
    func configureView(_ item: CardTransactionViewItemRepresentable?) {
        detailsStackView.removeAllArrangedSubviews()
        guard let configuration = item?.viewConfigurationRepresentable else { return }
        configuration.map { config in
            let detail = TransactionDetailView()
            let leftConfig = getViewConfigurationForRepresentable(config.leftRepresentable)
            let rightConfig = getViewConfigurationForRepresentable(config.rightRepresentable)
            let configuration = CardTransactionDetailViewConfiguration(left: leftConfig,
                                                                       right: rightConfig)
            detail.setConfiguration(configuration)
            return detail
        }
        .forEach { detailsStackView.addArrangedSubview($0) }
    }
}

private extension CardTransactionCollectionInfoView {
    func getViewConfigurationForRepresentable(_ representable: CardTransactionDetailViewRepresentable?) -> CardTransactionDetailViewRepresentable? {
        guard let oldRepresentable = representable else { return nil }
        if representable?.value == nil {
            return CardTransactionDetailView(title: oldRepresentable.title,
                                              value: getValueForType(oldRepresentable.viewType))
        } else {
            return oldRepresentable
        }
    }
    
    func getValueForType(_ type: CardTransactionDetailViewType?) -> NSAttributedString? {
        guard let viewType = type,
              let unwrappedItem = self.item else { return nil }
        switch viewType {
        case .operationDate:
            return getOperationDate(transaction: unwrappedItem.transaction,
                             detail: unwrappedItem.transactionDetail)
        case .annotationDate:
            return getAnnotationDate(transaction: unwrappedItem.transaction)
        case .liquidation:
            return getSoldOutDate(detail: unwrappedItem.transactionDetail)
        case .fees:
            return nil
        }
    }
    
    func getOperationDate(transaction: CardTransactionRepresentable,
                          detail: CardTransactionDetailRepresentable?) -> NSAttributedString {
        let date = timeManager?.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
        guard let time = getOperationTime(detail: detail) else {
            let date = timeManager?.toString(date: transaction.operationDate, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
            let time = timeManager?.toString(date: transaction.operationDate, outputFormat: .HHmm) ?? ""
            return getFormattedOperationDate(date: date, time: time)
        }
        return getFormattedOperationDate(date: date, time: time)
    }
    
    func getOperationTime(detail: CardTransactionDetailRepresentable?) -> String? {
        guard let time = detail?.transactionDate else { return nil }
        guard let dateString = timeManager?.toString(input: time,
                                                    inputFormat: TimeFormat.HHmmssZ,
                                                    outputFormat: TimeFormat.HHmm)
        else { return nil }
        return dateString
    }

    func getFormattedOperationDate(date: String, time: String) -> NSAttributedString {
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let fullText = time.isEmpty ? date : "\(date) · \(time)"
        return TextStylizer.Builder(fullText: fullText)
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: date).setStyle(font))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: "· \(time)").setStyle(font.withSize(11)))
            .build()
    }
    
    func getAnnotationDate(transaction: CardTransactionRepresentable) -> NSAttributedString? {
        guard let value = timeManager?.toString(date: transaction.annotationDate,
                                        outputFormat: .dd_MMM_yyyy)?.lowercased()
        else { return nil }
        return NSAttributedString(string: value)
    }
    
    func getSoldOutDate(detail: CardTransactionDetailRepresentable?) -> NSAttributedString {
        guard let transactionDetail = detail,
              transactionDetail.isSoldOut,
              let date = transactionDetail.soldOutDate
        else {
            let value = timeManager?.toString(date: Date(),
                                             outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
            return NSAttributedString(string: value)
        }
        let value = timeManager?.toString(date: date, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
        return NSAttributedString(string: value)
    }
}
