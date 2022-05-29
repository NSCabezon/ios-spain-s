//
//  AccessibilityFractionablePurchaseDetail.swift
//  Commons
//
//  Created by Ignacio González Miró on 1/6/21.
//

import Foundation

public enum AccessibilityFractionablePurchaseDetail {
    // MARK: - CollectionView Main
    public static let containerView = "fractionatePurchasesListInstalment"
    public static let expandOrCollapseButton = "fractionablePurchaseDetailExpandOrCollapseButton"
    public static let tornImageView = "imgTorn"
    public static let collectionView = "fractionatePurchasesCarouselInstalment"
    
    // MARK: - CollectionView Cell subviews
    // MARK: Amortized view
    public static let amortizedBaseView = "fractionablePurchaseDetailAmortizedBaseView"
    public static let amortizedTitleLabel = "fractionatePurchases_label_capitalRepaid"
    public static let amortizedValueLabel = "fractionablePurchaseDetailAmortizedValueLabel"
    public static let amortizedTotalAmountTitleLabel = "easyPay_label_totalAmount"
    public static let amortizedTotalAmountValueLabel = "fractionablePurchaseDetailAmortizedTotalAmountValueLabel"

    // MARK: CardDetail view
    public static let cardDetailBaseView = "fractionablePurchaseDetailCardDetailBaseView"
    public static let cardDetailTitleLabel = "fractionablePurchaseDetailCardDetailTitleLabel"
    public static let cardDetailCardTypeLabel = "fractionablePurchaseDetailCardDetailCardTypeLabel"

    // MARK: FeeDetail view
    public static let feeDetailBaseView = "fractionablePurchaseDetailFeeDetailBaseView"
    public static let feeDetailAmountLabel = "fractionablePurchaseDetailFeeDetailAmountLabel"
    public static let feeDetailTitleLabel = "transaction_label_pendingAmount"
    public static let feeDetailNumOfFeeLabel = "fractionatePurchases_label_instalmentsValue"

    // MARK: OperationDetail view
    public static let operationDetailBaseView = "fractionablePurchaseDetailOperationDetailBaseView"
    public static let operationDetailOperationDateTitleLabel = "transaction_label_operationDate"
    public static let operationDetailOperationDateLabel = "fractionablePurchaseDetailOperationDetailOperationDateLabel"
    public static let operationDetailDateTitleLabel = "fractionatePurchases_label_deferDate"
    public static let operationDetailDateLabel = "fractionablePurchaseDetailOperationDetailDateLabel"

    // MARK: MoreInfo view
    public static let moreInfoBaseView = "fractionablePurchaseDetailMoreInfoBaseView"
    public static let moreInfoNumOfMonthsTitleLabel = "fractionablePurchaseDetailMoreInfoNumOfMonthsTitleLabel"
    public static let moreInfoNumOfMonthsLabel = "easyPay_label_toPay"
    public static let moreInfoFeeTitleLabel = "fractionatePurchases_label_instalment"
    public static let moreInfoFeeLabel = "fractionablePurchaseDetailMoreInfoFeeLabel"
    public static let moreInfoInterestsTitleLabel = "easyPay_label_interest"
    public static let moreInfoInterestsLabel = "fractionablePurchaseDetailMoreInfoInterestsLabel"
    public static let moreInfoCapitalTitleLabel = "transaction_label_amount"
    public static let moreInfoCapitalLabel = "fractionablePurchaseDetailMoreInfoCapitalLabel"
    
    // MARK: FeeDetail ErrorView
    public static let feeDetailErrorBaseView = "fractionablePurchaseDetailFeeDetailErrorBaseView"
    public static let feeDetailErrorNumOfFeesLabel = "fractionatePurchases_label_instalmentsValue"
    public static let feeDetailErrorProgressView = "fractionablePurchaseDetailFeeDetailErrorProgressView"
}
