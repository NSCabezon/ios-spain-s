//
//  LoanTransactionCollectionViewCell.swift
//  Loans
//
//  Created by Ernesto Fernandez Calles on 24/8/21.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import CoreDomain

final class LoanTransactionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet private weak var spaceToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLabelView: OneLabelHighlightedView!
    private var viewModel: LoanTransactionDetail?
    var state: ResizableState = .expanded
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppareance()
        self.setAccessibilityIds()
    }
    
    func configure(_ viewModel: LoanTransactionDetail) {
        self.detailStackView.removeAllArrangedSubviews()
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        self.aliasLabel.text = viewModel.alias
        self.amountLabelView.attributedText = viewModel.formattedAmount
        self.amountLabelView.style = viewModel.isTransactionNegative ? .clear : .lightGreen
        viewModel.transactionDetailConfiguration.fields.forEach { row in
            addNewLine(leftConfiguration: row.0,
                       leftValue: viewModel.valueFromDetailValueField(row.0.value),
                       rightConfiguration: row.1,
                       rightValue: viewModel.valueFromDetailValueField(row.1?.value))
        }
        containerView.layoutIfNeeded()
    }
    
    func setContainerAccessibilityId(_ accessibilityId: String) {
        self.containerView.accessibilityIdentifier = accessibilityId
    }
    
    func contentViewHeight() -> CGFloat {
        return containerView.bounds.height
    }
}

private extension LoanTransactionCollectionViewCell {
    func setAppareance() {
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.backgroundColor = UIColor.white
    }
    
    func setAccessibilityIds() {
        self.titleLabel.accessibilityIdentifier = AccessibilityIDLoansTransactionsDetail.itemTitle.rawValue
        self.aliasLabel.accessibilityIdentifier = AccessibilityIDLoansTransactionsDetail.itemAlias.rawValue
        self.amountLabelView.accessibilityIdentifier = AccessibilityIDLoansTransactionsDetail.itemAmount.rawValue
    }
    
    func addNewLine(leftConfiguration: LoanTransactionDetailFieldRepresentable,
                    leftValue: String?,
                    rightConfiguration: LoanTransactionDetailFieldRepresentable? = nil,
                    rightValue: String?) {
        let newStackView = InfoStackView(frame: .zero)
        newStackView.setLeft(title: localized(leftConfiguration.title),
                             info: leftValue ?? "",
                             titleAccessibility: leftConfiguration.titleAccessibility,
                             infoAccessibility: leftConfiguration.valueAccessibility)
        if let right = rightConfiguration {
            newStackView.setRight(title: localized(right.title),
                                  info: rightValue ?? "",
                                  titleAccessibility: right.titleAccessibility,
                                  infoAccessibility: right.valueAccessibility)
        }
        if newStackView.arrangedSubviews.isNotEmpty {
            self.detailStackView.addArrangedSubview(newStackView)
        }
    }
}

private final class StackConfiguration {
    let title: String
    let titleAccessibility: String
    let info: String
    let infoAccessibility: String
    
    init(title: String, titleAccessibility: String, info: String?, infoAccessibility: String) {
        self.title = info != nil ? title : ""
        self.titleAccessibility = titleAccessibility
        self.info = info ?? ""
        self.infoAccessibility = infoAccessibility
    }
}

private class InfoStackView: UIStackView {
    private lazy var leftTitleLabel: UILabel = {
        let label = commonLabel(UIColor.grafite)
        leftStackView.addArrangedSubview(label)
        return label
    }()
    
    private lazy var leftInfoLabel: UILabel = {
        let label = commonLabel(UIColor.lisboaGray)
        leftStackView.addArrangedSubview(label)
        return label
    }()
    
    private lazy var rightTitleLabel: UILabel = {
        let label = commonLabel(UIColor.grafite)
        rightStackView.addArrangedSubview(label)
        return label
    }()
    
    private lazy var rightInfoLabel: UILabel = {
        let label = commonLabel(UIColor.lisboaGray)
        rightStackView.addArrangedSubview(label)
        return label
    }()
    
    private lazy var leftStackView: UIStackView = {
        return commonStackView()
    }()
    
    private lazy var rightStackView: UIStackView = {
        return commonStackView()
    }()
    
    private func commonLabel(_ color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = UIFont.santander(size: 13.0)
        label.textColor = color
        label.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        return label
    }
    
    private func commonStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        self.addArrangedSubview(stackView)
        return stackView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.alignment = .top
        self.spacing = 8
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLeft(title: String, info: String, titleAccessibility: String, infoAccessibility: String) {
        leftTitleLabel.text = title
        leftTitleLabel.accessibilityIdentifier = titleAccessibility
        leftInfoLabel.text = info
        leftInfoLabel.accessibilityIdentifier = infoAccessibility
    }
    
    func setRight(title: String, info: String, titleAccessibility: String, infoAccessibility: String) {
        rightTitleLabel.text = title
        rightTitleLabel.accessibilityIdentifier = titleAccessibility
        rightInfoLabel.text = info
        rightInfoLabel.accessibilityIdentifier = infoAccessibility
    }
}

class OldLoanTransactionCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var transactionDateDescriptionLabel: UILabel!
    @IBOutlet private weak var transactionDateLabel: UILabel!
    @IBOutlet private weak var effectiveDateDescriptionLabel: UILabel!
    @IBOutlet private weak var effectiveDateLabel: UILabel!
    @IBOutlet private weak var capitalDescritionLabel: UILabel!
    @IBOutlet private weak var capitalValueLabel: UILabel!
    @IBOutlet private weak var interestDescriptionLabel: UILabel!
    @IBOutlet private weak var interestValueLabel: UILabel!
    @IBOutlet private weak var recipientAccountDescriptionLabel: UILabel!
    @IBOutlet private weak var recipientAccountValueLabel: UILabel!
    @IBOutlet private weak var recipientDataDescriptionLabel: UILabel!
    @IBOutlet private weak var recipientDataValueLabel: UILabel!
    @IBOutlet private weak var detailStackView: UIStackView!
    @IBOutlet private weak var spaceToBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var positiveAmountBackgroundView: UIView!

    private var viewModel: OldLoanTransactionDetailViewModel?
    var state: ResizableState = .expanded
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppareance()
    }
    
    func configure(_ viewModel: OldLoanTransactionDetailViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
        self.aliasLabel.text = viewModel.alias
        self.amountLabel.attributedText = viewModel.formattedAmount
        self.positiveAmountBackgroundView.isHidden = viewModel.isTransactionNegative
        self.transactionDateDescriptionLabel.text = localized("transaction_label_operationDate")
        self.transactionDateLabel.text = viewModel.operationDate
        self.effectiveDateDescriptionLabel.text = localized("transaction_label_valueDate")
        self.effectiveDateLabel.text = viewModel.annotationDate
        self.capitalDescritionLabel.text = localized("transaction_label_amount")
        self.capitalValueLabel.text = viewModel.formattedCapitalAmount
        self.interestDescriptionLabel.text = localized("transaction_label_interests")
        self.interestValueLabel.text = viewModel.formattedInterestAmount
        self.recipientAccountDescriptionLabel.text = localized("transaction_label_recipientAccount")
        self.recipientAccountValueLabel.text = viewModel.recipientAccountNumber
        self.recipientDataDescriptionLabel.text = localized("transaction_label_recipientData")
        self.recipientDataValueLabel.text = viewModel.recipientData
    }
}

extension OldLoanTransactionCollectionViewCell {
    private func setAppareance() {
        self.containerView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containerView.layer.borderWidth = 1
        self.containerView.backgroundColor = UIColor.white
        self.positiveAmountBackgroundView.layer.cornerRadius = 4.0
        self.positiveAmountBackgroundView.backgroundColor = UIColor.greenIce
    }
}
