//
//  AccessibilityGlobalPosition.swift
//  Commons
//
//  Created by Laura González on 06/03/2020.
//

import Foundation

public enum AccessibilityGlobalPositionSmart: String {
    case btnAccount
    case btnNewSend
    case btnNewContacts
    case btnTransferAcount
    case icnCloseOffer
    case imgOffer
    case btnStartUsing = "pg_button_startUsing"
}

public enum AccessibilityGlobalPosition {
    public static let btnStartUsing = "pg_button_startUsing"
    public static let btnYourBalanceToolTip = "btnYourBalanceToolTip"
    public static let bubbleYourBalanceToolTip = "bubbleYourBalanceToolTip"
    public static let btnMoreOptionsShortcuts = "pgBtnMoreOptions"
    public static let collapsableGeneralHeader = "collapsableGeneralHeader"
    public static let movementGeneralHeader = "movementsGeneralHeader"
    public static let logoSantander =  "logoSantander"
    public static let gradientColumn = "gradientColumn"
    public static let verticalExpenseInfo = "verticalExpenseInfo"
    public static let obtionBarPlusButton = "obtionBarPlusButton"
    public static let defaultButton = "defaultButton"
    public static let offerCell = "offerCell"
    public static let graphContainer = "pgGraphContainer"
    public static let objetiveButton = "objetiveButton"
    public static let pgSearchInputTextWhatNeed = "globalSearch_inputText_whatNeed"
    public static let icnSanSmall = "icnSanSmall"
    public static let generalProductSimpleCellTitleLabel = "generalProductSimpleCellTitleLabel"
    public static let generalProductSimpleCellSubtitleLabel = "generalProductSimpleCellSubtitleLabel"
    public static let generalProductSimpleCellValueLabel = "generalProductSimpleCellValueLabel"
    public static let generalProductSimpleCellMovementsRowLabel = "generalProductSimpleCellMovementsRowLabel"
    public static let generalProductSimpleCellTitleAmountRowAmountLabel = "generalProductSimpleCellTitleAmountRowAmountLabel"
    public static let icnSmallInfo = "icnSmallInfo"
    public static let generalProductSimpleHeaderRegardLabel = "generalProductSimpleHeaderRegardLabel"
    public static let generalProductSimpleHeaderYourMoneyLabel = "generalProductSimpleHeaderYourMoneyLabel"
    public static let generalProductSimpleHeaderMoneyNumberLabel = "generalProductSimpleHeaderMoneyNumberLabel"
    
    // MARK: Header
    public static let pgTitleWelcome = "pg_title_welcome"
    public static let pgLabelTotMoney = "pg_label_totMoney"
    public static let pgLabeTotMoneyValue = "pgLabeTotMoneyValue"
    public static let icnInfoWhitePG = "icnInfoWhitePG"
    public static let pgLabelTotFinancing = "pg_label_totFinancing"
    public static let pgLabelTotFinancingValue = "pgLabelTotFinancingValue"
    public static let pgLabelYourExpenses = "pg_label_yourExpenses"
    public static let pgLabelBudget = "pg_label_budget"
    public static let pgLabelExpenses = "pg_label_expenses"
    
    // MARK: Products
    public static let pgBasketLabelTransaction = "pgBasket_label_transaction"
    public static let pgBasketLabelTransactionValue = "pgBasketLabelTransactionValue"
    
    // MARK: Products(Accounts)
    public static let pgProductTitleAccount = "pgProduct_title_account"
    public static let pgProductAliasAccount = "pgProductAliasAccount"
    public static let pgProductAccountNumber = "pgProductAccountNumber"
    public static let pgBasketLabelBalance = "pgBasket_label_balance"
    public static let pgBasketLabelBalanceValue = "pgBasketLabelBalanceValue"
    public static let imgPGPiggyBank = "pgImgPiggyBank"
    
    // MARK: Products(Cards)
    public static let pgProductTitleCard = "pgProduct_title_card"
    public static let pgProductAliasCard = "pgProductAliasCard"
    public static let pgProductCardNumber = "pgProductCardNumber"
    public static let pgLabelOutstandingBalanceDots = "pg_label_outstandingBalanceDots"
    public static let pgLabelOutstandingBalanceDotsValue = "pgLabelOutstandingBalanceDotsValue"
    public static let pgProductImgCard = "pgImgCard"
    
    // MARK: Products(Generic)
    public static let pgProductTitleGeneric = "pgProduct_title_generic"
    public static let pgProductAliasGeneric = "pgProductAliasGeneric"
    public static let pgProductGenericNumber = "pgProductGenericNumber"
    public static let pgProductLabelBalanceDots = "pg_product_label_balanceDots"
    public static let pgProductLabelBalanceDotsValue = "pgProductLabelBalanceDotsValue"
}

public enum AccessibilityAvios {
    public static let pgBtnZonaAvios = "pgBtnZonaAvios"
    public static let aviosViewConsultation = "aviosViewConsultation"
}

public enum AccessibilityRecoveredMoney {
    public static let collapseIndicatorContainer = "pgViewCollapseIndicatorContainer"
    public static let collapseIndicatorView = "pgViewCollapseIndicatorView"
}

public enum AccessibilityShortcuts {
     public static let pgLabelDirectAccess = "pgCustomize_label_directAccess"
 }
