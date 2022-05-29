//
//  AccessibilityExpensesAnalysis.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 30/6/21.
//

import Foundation

public enum AccessibilityExpensesAnalysisConfig {
    public static let headerTitle = "analysis_label_yourProducts"
    public static let headerSubtitle = "analysis_label_chooseProducts"
    public static let headerLastUpdate = "analysis_label_lastUpdate"
    public static let accountsHeaderLabel = "analysis_label_accountsHeader"
    public static let accountsHeaderCheckBox = "analysis_checkBox_accountsHeader"
    public static let cardsHeaderLabel = "analysis_label_cardsHeader"
    public static let cardsHeaderCheckBox = "analysis_checkBox_cardsHeader"
    public static let accountNameLabel = "analysis_label_accountName"
    public static let accountIbanLabel = "analysis_label_accountIban"
    public static let accountBankImage = "analysis_imageView_accountBankImage"
    public static let accountAmountLabel = "analysis_label_accountAmount"
    public static let accountCheckBox = "analysis_checkBox_account"
    public static let cardNameLabel = "analysis_label_cardName"
    public static let cardShortPanLabel = "analysis_label_cardPAN"
    public static let cardImageView = "analysis_imageView_cardImage"
    public static let cardBankImageView = "analysis_imageView_cardBankImage"
    public static let cardAvailableLabel = "analysis_label_cardAvailable"
    public static let cardAmountLabel = "analysis_label_cardAmountAvailable"
    public static let cardCheckBox = "analysis_checkBox_card"
    public static let footerOtherBanksLabel = "analysis_label_myOtherBanks"
    public static let footerOtherBanksButton = "analysis_button_otherBank"
    public static let footerOtherBanksStackView = "analysis_listView_otherBanks"
    public static let footerAddOtherBanksButton = "analysis_button_addOtherBanks"
}

public enum AccessibilityExpensesAnalysisBankConfigDetail {
    public static let accountAliasLabel = "analysis_label_accountAlias"
    public static let cccLabel = "analysis_label_ccc"
    public static let bankCellImage = "analysis_imageView_accountBankImage"
    public static let amountLabel = "analysis_label_amount"
    public static let checkBoxCellImage = "analysis_checkBox_account"
    public static let headerTitleLabel = "analysis_label_headerTitle"
    public static let checkBoxHeaderImage = "analysis_checkbox_header"
    public static let bankHeaderImage = "analysis_imageView_headerBankImage"
    public static let numberOfProductsLabel = "analysis_label_product_other"
    public static let lastConnectionLabel = "analysis_label_lastUpdate"
    public static let shieldImage = "analysis_imageView_securityShield"
    public static let safeLabel = "analysis_label_safeEnvironment"
    public static let accessKeyUpdateLabel = "analysis_button_updateAccessKeys"
    public static let lockerImage = "analysis_imageView_locker"
    public static let deleteConnectionLabel = "analysis_button_removeConnection"
    public static let trashCanImage = "analysis_imageView_trashCan"
    public static let safeEnvironmentCell = "analysis_cell_environment"
    public static let bankTitleCell = "analysis_cell_bankTitle"
    public static let lastConnectionCell = "analysis_cell_lastConnection"
    public static let accountsHeaderCell = "analysis_cell_accountsHeader"
    public static let accountProductConfigCell = "analysis_cell_accountProduct"
    public static let updateAccessKeysCell = "analysis_cell_updateAccessKeys"
    public static let deleteConnectionWithEntityCell = "analysis_cell_deleteConnection"
}

public enum AccessibilityExpensesAnalysisTimeSelector {
    public static let titleLabel = "analysis_label_chosenTemporalView"
    public static let monthlyView = "analysis_tab_monthlyView"
    public static let annualView = "analysis_tab_annualView"
    public static let quarterlyView = "analysis_tab_quarterlyView"
    public static let customPeriodView = "analysis_tab_customPeriodView"
}

public enum AccessibilityExpensesAnalysisHome {
    public static let expenditureSegmented = "analysis_label_expenditureAnalysis"
    public static let savingsHealthSegmented = "analysis_label_savingsHealth"
}

public enum AccesibilityExpenseIncomeCategoryType {
    public static let education = "categorization_label_education"
    public static let transport = "categorization_label_transport"
    public static let leisure = "categorization_label_leisure"
    public static let health = "categorization_label_health"
    public static let otherExpenses = "categorization_label_otherExpenses"
    public static let helps = "categorization_label_helps"
    public static let atms = "categorization_label_atms"
    public static let banksAndInsurances = "categorization_label_banksAndInsurances"
    public static let home = "categorization_label_home"
    public static let managements = "categorization_label_managements"
    public static let payroll = "categorization_label_payroll"
    public static let purchasesAndFood = "categorization_label_purchasesAndFood"
    public static let saving = "categorization_label_saving"
    public static let taxes = "categorization_label_taxes"
}

public enum AccesibilityCategoryDetailType {
    public static let alias = "analysisDetail_label_alias"
    public static let productAlias = "analysisDetail_label_productAlias"
    public static let amount = "analysisDetail_label_amount"
    public static let idDetail = "analysisDetail_label_idDetail"
    public static let subcategory = "analysisDetail_label_subcategory"
    public static let detailCell = "analysisDetail_label_cell"
    public static let mensualFilter = "analysisDetail_label_mensualFilter"
    public static let detailMonth = "analysisDetail_label_september"
    public static let buttonSettings = "analysisDetail_button_settings"
    public static let detailMovements = "analysisDetail_label_movements"
    public static let empty = "analysisDetail_label_emptyMovements"
    public static let category = "analysisDetail_label_category"
    public static let categoryImage = "analysisDetail_image_categoryImage"
    public static let arrow = "analysisDetail_image_arrow"
}
