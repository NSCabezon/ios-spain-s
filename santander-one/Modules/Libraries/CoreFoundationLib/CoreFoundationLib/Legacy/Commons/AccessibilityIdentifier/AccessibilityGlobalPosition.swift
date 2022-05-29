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
    case btnStartUsing = "pgSmart_card_startUsing"
}

public enum AccessibilityGlobalPosition {
    public static let btnStartUsing = "pg_button_startUsing"
    public static let btnStartUsingArrow = "pg_image_startUsingArrow"
    public static let btnYourBalanceToolTip = "btnYourBalanceToolTip"
    public static let bubbleYourBalanceToolTip = "bubbleYourBalanceToolTip"
    public static let btnMoreOptionsShortcuts = "pgBtnMoreOptions"
    public static let btnMoreOptionsShortcutsBack = "pgBtnMoreOptionsBack"
    public static let collapsableGeneralHeader = "collapsableGeneralHeader"
    public static let movementGeneralHeader = "movementsGeneralHeader"
    public static let logoSantander =  "logoSantander"
    public static let gradientColumn = "gradientColumn"
    public static let verticalExpenseInfo = "verticalExpenseInfo"
    public static let obtionBarPlusButton = "obtionBarPlusButton"
    public static let defaultButton = "defaultButton"
    public static let offerCell = "offerCell"
    public static let offerCellCloseImage = "offerCell_image_close"
    public static let offerCellImage = "offerCell_image"
    public static let graphContainer = "pgGraphContainer"
    public static let objetiveButton = "objetiveButton"
    public static let leftMonth = "pg_label_leftMonth"
    public static let middleMonth = "pg_label_middleMonth"
    public static let rightMonth = "pg_label_rightMonth"
    public static let graphLoadingView = "pg_image_loading"
    public static let pgSearchInputTextWhatNeed = "globalSearch_inputText_whatNeed"
    
    // MARK: General
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
    
    // MARK: Classic Bar
    public static let titleBarLabel = "titleLabel"
    public static let firstBarReference = "firstReferenceLabel"
    public static let secondBarReference = "secondReferenceLabel"
    public static let tooltipBar = "tooltipButton"
    public static let loadingBarView = "pgClassic_header_loadingView"
    public static let loadingBarImage = "pgClassic_header_loadingImageView"
    
    // MARK: Header
    public static let pgTitleWelcome = "pg_title_welcome"
    public static let pgLabelTotMoney = "pg_label_totMoney"
    public static let pgLabeTotMoneyValue = "pgLabeTotMoneyValue"
    public static let icnInfoWhitePG = "icnInfoWhitePG"
    public static let pgLabelTotFinancing = "pg_label_totFinancing"
    public static let pgLabelTotFinancingValue = "pgLabelTotFinancingValue"
    public static let pgLabelYourExpenses = "pg_label_yourExpenses"
    public static let pgLabelBudget = "pg_label_budget"
    public static let pgImageBudget = "pg_image_budget"
    public static let pgLabelExpenses = "pg_label_expenses"
    public static let pgImageExpenses = "pg_image_expenses"
    public static let pgYourMoney = "classicPgUser_yourMoney"
    public static let pgYourMoneyValue = "classicPgUser_yourMoneyValue"
    public static let pgInfoImage = "img_classicPgUser_yourMoneyToolTip"
    public static let pgBtnContext = "pgBtnContext"
    
    // MARK: Products
    public static let pgSmartAccountLabelTransaction = "pgSmart_account_transactionLabel"
    public static let pgSmartAccountLabelTransactionValue = "pgSmart_account_TransactionValueLabel"
    public static let pgSmartCardLabelTransaction = "pgSmart_card_transactionLabel"
    public static let pgSmartCardLabelTransactionValue = "pgSmart_card_TransactionValueLabel"
    
    // MARK: Products(Accounts)
    public static let pgProductViewAccount = "pgSmart_account_view"
    public static let pgProductTitleAccount = "pgSmart_account_titleLabel"
    public static let pgProductAliasAccount = "pgSmart_account_aliasLabel"
    public static let pgProductAccountNumber = "pgSmart_account_numberLabel"
    public static let pgBasketLabelBalance = "pgSmart_account_balanceLabel"
    public static let pgBasketLabelBalanceValue = "pgSmart_account_balanceValueLabel"
    public static let imgPGPiggyBank = "pgImgPiggyBank"
    
    // MARK: Products(Cards)
    public static let pgProductViewCard = "pgSmart_card_view"
    public static let pgProductTitleCard = "pgSmart_card_titleLabel"
    public static let pgProductAliasCard = "pgSmart_card_aliasLabel"
    public static let pgProductCardNumber = "pgSmart_card_number"
    public static let pgLabelOutstandingBalanceDots = "pgSmart_card_outstandingBalanceDots"
    public static let pgLabelOutstandingBalanceDotsValue = "pgSmart_card_outstandingBalanceDotsValue"
    public static let pgProductImgCard = "pgSmart_card_image"
    public static let pgSimpleCardView = "pgSimple_card"
    public static let pgSimpleCardTitle = "pgSimple_card_name"
    public static let pgSimpleCardNumb = "pgSimple_card_num"
    public static let pgSimpleCardValue = "pgSimple_card_value"
    public static let pgSimpleCardValueDesc = "pgSimple_card_valueDesc"
    public static let pgSimpleCardActivateBtn = "pgSimple_card_activateBtn"
    public static let pgSimpleCardArrowActivateImage = "pgSimple_card_activateArrowImage"
    public static let pgSimpleCardMovementNumb = "pgSimple_card_movementNumb"
    public static let pgSimpleCardMovementLabel = "pgSimple_card_movementLabel"
    public static let pgClassicCardView = "pgClassic_card"
    public static let pgClassicCardName = "pgClassic_card_name"
    public static let pgClassicCardNum = "pgClassic_card_num"
    public static let pgClassicCardValueDesc = "pgClassic_card_valueDesc"
    public static let pgClassicCardValue = "pgClassic_card_value"
    public static let pgClassicCardMovDesc = "pgClassic_card_movDesc"
    public static let pgClassicCardMovNum = "pgClassic_card_movNum"
    public static let pgClassicCardActivateLabel = "pgClassic_card_activateLabel"
    public static let pgClassicCardActivateArrow = "pgClassic_card_activateArrow"
    
    // MARK: Products(Generic)
    public static let pgProductTitleGeneric = "pgProduct_title_generic"
    public static let pgProductAliasGeneric = "pgProductAliasGeneric"
    public static let pgProductGenericNumber = "pgProductGenericNumber"
    public static let pgProductLabelBalanceDots = "pg_product_label_balanceDots"
    public static let pgProductLabelBalanceDotsValue = "pgProductLabelBalanceDotsValue"
    public static let pgSimpleGenericTitle = "pgSimple_account_title"
    public static let pgSimpleGenericSubtitle = "pgSimple_account_subtitle"
    public static let pgSimpleGenericValue = "pgSimple_account_value"
    //public static let pgClassicGenericTitle = "pgClassic_account_title"
    //public static let pgClassicGenericSubtitle = "pgClassic_account_subtitle"
    //public static let pgClassicGenericValue = "pgClassic_account_value"
    
    // MARK: InterventionFilter
    public static let pgFilterView = "pg_filter_view"
    public static let pgFilterTitleLabel = "pg_filter_title"
    public static let pgFilterUserIcn = "pg_filter_UserIcn"
    public static let pgFilterOptionsLabel = "pg_filter_optionTitle"
    public static let pgFilterOptionsExpandClosed = "icnExpandMoreClosed"
    public static let pgFilterOptionsExpandOpen = "icnExpandMoreOpen"
    
    // MARK: InterventionFilterOptions
    public static let pgFilterOptionsView = "pg_filter_optionsView"
    public static let pgFilterOptionsAll = "pg_filer_allLabel"
    public static let pgFilterOptionsOwner = "pg_filer_ownerLabel"
    public static let pgFilterOptionsAuth = "pg_filer_authorizedLabel"
    public static let pgFilterOptionsRepresentative = "pg_filer_representativeLabel"
    
    // MARK: Configure
    public static let pgConfigureIcn = "pg_configure_view"
    public static let pgConfigureTitleLabel = "pg_configure_title"
    public static let pgConfigureView = "pg_configure_view"
}

public enum AccessibilityAvios {
    public static let pgBtnZonaAvios = "pgBtnZonaAvios"
    public static let aviosViewConsultation = "aviosViewConsultation"
}

public enum AccessibilityRecoveredMoney {
    public static let collapseIndicatorContainer = "pgViewCollapseIndicatorContainer"
    public static let collapseIndicatorView = "pgViewCollapseIndicatorView"
    public static let leftScroll = "pgCarouselPreviousPendingContract"
    public static let rightScroll = "pgCarouselNextPendingContract"
}

public enum AccessibilityShortcuts {
     public static let pgLabelDirectAccess = "pgCustomize_label_directAccess"
 }
