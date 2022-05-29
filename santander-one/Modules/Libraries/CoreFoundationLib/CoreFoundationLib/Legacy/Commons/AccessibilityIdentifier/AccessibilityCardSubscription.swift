//
//  AccessibilityCardSubscription.swift
//  Commons
//
//  Created by Ignacio González Miró on 13/4/21.
//

import Foundation

public enum AccessibilityCardSubscription {
    public static let cardHeaderBaseView = "m4mHeaderBaseView"
    public static let cardHeaderCardImageView = "m4mHeaderImgCard"
    public static let cardHeaderTitleLabel = "m4mHeaderAlias_Card"
    public static let cardHeaderDescriptionLabel = "m4mHeaderNum_Card"
    public static let cardHeaderNumEnabledShopsLabel = "m4m_label_activeCommerce"
    
    public static let seeMoreBaseView = "cardSubscriptionSeeMoreBaseView"
    public static let seeMoreTitleLabel = "cardSubscriptionSeeMoreTitleLabel"
    public static let seeMoreImageView = "cardSubscriptionSeeMoreImageView"

    public static let purchaseBaseView = "cardSubscriptionPurchaseBaseView"
    public static let purchaseNameLabel = "cardSubscriptionPurchaseNameLabel"
    public static let purchaseDateLabel = "cardSubscriptionPurchaseDateLabel"
    public static let purchaseAmountLabel = "cardSubscriptionPurchaseAmountLabel"

    public static let purchaseImageUrlImageView = "cardSubscriptionPurchaseImageBaseView"
    public static let purchaseImageCircleView = "cardSubscriptionPurchaseImageCircleView"
    public static let purchaseImageInitialsLabel = "cardSubscriptionPurchaseImageInitialsLabel"
}

public enum AccessibilityCardSubscriptionDetail {
    // CardDetail
    public static let detailBaseView = "cardSubscriptionDescriptionBaseView"
    public static let detailContentView = "cardSubscriptionDescriptionContentView"

    public static let detailHeaderBaseView = "cardSubscriptionDetailHeaderBaseView"
    public static let detailHeaderTitleLabel = "cardSubscriptionDetailHeaderTitleLabel"
    public static let detailHeaderImageView = "cardSubscriptionDetailHeaderImageView"

    public static let detailCardDetailBaseView = "cardSubscriptionCardDetailBaseView"
    public static let detailCardDetailStaticLabel = "m4m_label_card"
    public static let detailCardDetailAliasLabel = "cardSubscriptionCardDetailAliasLabel"
    public static let detailCardDetailNumberLabel = "cardSubscriptionCardDetailNumberLabel"
    public static let detailCardDetailImageView = "cardSubscriptionCardDetailCardImageView"

    public static let detailDateBaseView = "cardSubscriptionDateDetailBaseView"
    public static let detailDateStartLabel = "m4m_label_startedOn"
    public static let detailDateDateLabel = "cardSubscriptionDateDetailDateLabel"

    public static let subscriptionPaymentBaseView = "cardSubscriptionPaymentBaseView"
    public static let subscriptionPaymentToolTip = "cardSubscriptionPaymentToolTipView"
    public static let subscriptionPaymentStatusLabel = "cardSubscriptionPaymentStatusLabel"
    public static let subscriptionPaymentSwitch = "cardSubscriptionPaymentSwitch"
    
    // HistoricView
    public static let historicBaseView = "cardSubscriptionDetailHistoricBaseView"
    public static let historicTitleLabel = "cardSubscriptionDetailHistoricTitleLabel"
    public static let historicStackView = "m4mListPayHistory"
    
    public static let historicPillBaseView = "cardSubscriptionDetailHistoricPillBaseView"
    public static let historicPillDateLabel = "cardSubscriptionDetailHistoricPillDateLabel"
    public static let historicPillBaseViewTitleLabel = "cardSubscriptionDetailHistoricPillTitleLabel"
    public static let historicPillBaseViewAmountLabel = "cardSubscriptionDetailHistoricPillAmountLabel"
    
    // GraphView
    public static let graphBaseView = "cardSubscriptionDetailGraphBaseView"
    public static let graphCollectionView = "cardSubscriptionDetailGraphCollectionView"
    public static let graphTitleLabel = "m4m_label_evolutionAndAnalysis"
    
    public static let graphItemBaseView = "cardSubscriptionDetailGraphItemBaseView"
    public static let graphItemTitleTotalAnualSpentLabel = "m4m_label_paymentsTotal"
    public static let graphItemTitleAverageMonthlySpentLabel = "m4m_label_averageSpending"
    public static let graphItemTextTotalAnualSpentLabel = "cardSubscriptionDetailGraphItemTextTotalAnualSpentLabel"
    public static let graphItemTextAverageMonthlySpentLabel = "cardSubscriptionDetailGraphTextAverageMonthlySpentLabel"
    public static let graphItemImageView = "icnPaymentsTotal"

    public static let graphMonthlyItemBaseView = "cardSubscriptionDetailGraphItemBaseView"
    public static let graphMonthlyItemSpentLabel = "cardSubscriptionDetailGraphItemSpentLabel"
    public static let graphMonthlyItemTitleLabel = "cardSubscriptionDetailGraphItemTitleLabel"
}

public enum AccessibilityCardControlDistribution {
    public static let distributionItemBaseView = "cardControlDistributionItemBaseView"
    public static let distributionItemTitleLabel = "cardControlDistributionItemTitleLabel"
    public static let distributionItemDescriptionLabel = "cardControlDistributionItemDescriptionLabel"
    public static let distributionItemImageView = "cardControlDistributionItemImageView"
    public static let distributionItemActionLabel = "cardControlDistributionItemTitleLabel"
    public static let distributionItemFooterLabel = "cardControlDistributionItemFooterLabel"
    public static let distributionItemFooterImageView = "cardControlDistributionItemFooterImageView"
}
