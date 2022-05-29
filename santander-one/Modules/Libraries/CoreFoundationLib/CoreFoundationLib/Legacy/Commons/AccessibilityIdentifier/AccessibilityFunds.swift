//
//  AccessibilityFunds.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 9/3/22.
//

import Foundation

public enum AccessibilityIdFundLoading: String {
    case icnLoader
    case genericPopupLoadingContent = "generic_popup_loadingContent"
    case loadingLabelMoment = "loading_label_moment"
}

public enum AccessibilityIdFundEmptyList: String {
    case imgEmptyView = "ImgEmptyView"
    case genericLabelEmpty = "generic_label_empty"
    case genericLabelEmptyNotAvailableMoves = "generic_label_emptyNotAvailableMoves"
}

public enum AccessibilityIdFundHome: String {
    case fundsTitleDetails = "funds_title_details"
    case icnArrowUp
    case fundsTitleOrdersTransactions = "funds_title_ordersTransactions"
    case fundsBgDetails
    case fundsBgOrders
}

public enum AccessibilityIdFundCarouselCell: String {
    case fundsBgCard
    case fundsBgTag
    case fundsLabelTag
    case fundsLabelCarrouselAlias
    case fundsLabelFundNumber = "funds_label_fundNumber"
    case fundsIconShare = "icnShare"
    case fundsLabelTotalInvestment = "funds_label_totalInvestment"
    case fundsLabelCarrouselAmount
    case fundsLabelProfitability = "funds_label_profitability"
    case icnQuery
    case fundsLabelProfitabilityIncrease
    case icnIncrease
    case fundsLabelProfitabilityAmount
}

public enum AccessibilityIdFundHeader: String {
    case productCarouselTab
}

public enum AccessibilityIDFundDetail: String {
    case detailAssociatedAccount = "funds_label_associatedAccount"
    case detailAssociatedAccountValue = "funds_label_associatedAccount_value"
    case detailAlias = "funds_label_fundAlias"
    case detailAliasValue = "fundsLabelFundAlias"
    case detailOwner = "funds_label_owner"
    case detailOwnerValue = "fundsLabelOwner"
    case detailDescription = "funds_label_description"
    case detailDescriptionValue = "fundsLabelDescription"
    case detailDateOfValuation = "funds_label_dateValuation"
    case detailDateOfValuationValue = "fundsLabelDateValuation"
    case detailNumberOfUnits = "funds_label_numberUnits"
    case detailNumberOfUnitsValue = "fundsLabelNumberUnits"
    case detailValueOfAUnit = "funds_label_valueUnit"
    case detailValueOfAUnitValue = "fundsLabelValueUnitAmount"
    case detailTotalValue = "funds_label_totalValue"
    case detailTotalValueValue = "fundsLabelTotalValueAmount"
    case detailCategoryOfAUnit = "funds_label_categoryUnit"
    case detailCategoryOfAUnitValue = "fundsLabelCategoryUnit"
    case detailUnusedIsaAllowance = "funds_label_unusedIsaAllowance"
    case detailUnusedIsaAllowanceValue = "fundLabelUnusedIsaAllowanceAmount"
    case detailIsaWrapInPlace = "funds_label_isaWrap"
    case detailIsaWrapInPlaceValue = "fundLabelisaWrapValue"
    case detailFeesByDirectDebit = "funds_label_feesDirectDebit"
    case detailFeesByDirectDebitValue = "fundLabelFeesDirectDebitValue"
    case detailDividendReinvestment = "funds_label_dividendReinvestment"
    case detailDividendReinvestmentValue = "fundLabelDividendReinvestmentValue"
    case detailBalance = "funds_label_balance"
    case detailBalanceValue = "fundLabelBalanceAmount"
    case detailCurrentValue = "funds_label_currentValue"
    case detailCurrentValueAmountValue = "fundLabelCurrentValueAmount"
    case detailPriceAtLast = "funds_label_priceAtLast"
    case detailPriceAtLastValue = "fundLabelValue"
    case detailUnits = "funds_label_units"
    case detailUnitsValue = "fundLabelUnitsValue"
    case detailCurrentValueValue = "fundLabelCurrentValueValue"
}

public enum AccessibilityIdFundLastMovements: String {
    case fundsLabelDay
    case fundsLabelSubmittedTitle = "funds_label_submitted"
    case fundLabelSubmitted
    case fundsLabelTransactionsAlias
    case fundsLabelTransactionsAmount
    case fundsLabelUnits = "funds_label_units"
    case fundUnitsChevron
    case fundUnitsBtn = "btnArrowUp"
    case fundsLabelFundAlias = "funds_label_fundAlias"
    case fundsLabelFundAliasValue
    case fundsLabelAssociatedAccount = "funds_label_associatedAccount"
    case fundsLabelAssociatedAccountValue
    case fundsLabelTransactionFees = "funds_label_transactionFees"
    case fundsLabelTransactionFeesAmount
    case fundsLabelStatusTitle = "funds_label_status"
    case fundsLabelStatus
    case fundsButtonShare = "funds_button_share"
    case icnShare
    case fundsBgButton
    case fundsBgViewMore
    case fundsLabelViewMore = "funds_label_viewMore"
    case icnArrowRight
}

public enum AccessibilityIDFundMovementDetail: String {
    case detailAssociatedAccount = "funds_label_associatedAccount"
    case detailAssociatedAccountValue = "fundsLabelAssociatedAccountValue"
    case detailAlias = "funds_label_fundAlias"
    case detailAliasValue = "fundsLabelFundAliasValue"
    case detailStatus = "funds_label_status"
    case detailStatusValue = "fundsLabelStatus"
    case detailFees = "funds_label_transactionFees"
    case detailFeesValue = "fundsLabelTransactionFeesAmount"
}

public enum AccessibilityIdFundsTransactionsFilter: String {
    case startDateSuffix = "_startDate"
    case endDateSuffix = "_endDate"
    case searchLabelDatesRange = "search_label_datesRange"
    case searchLabelSince = "search_label_since"
    case searchLabelUntil = "search_label_until"
}

public enum AccessibilityIdFundsTransactions: String {
    case fundsLabelCarrouselAlias
    case fundsLabelMovements = "funds_label_Movements"
    case btnFilters
    case genericButtonFilters = "generic_button_filters"
    case fundsLabelCarrouselAliasBar
    case btnFiltersBar
    case genericButtonFiltersBar = "generic_button_filters_bar"
    case filterItemClear
    case filterItemDates
    case filterItemDatesValue
}

