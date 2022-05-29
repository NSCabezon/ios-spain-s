//
//  AccessibilityAnalysisArea.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 17/03/2020.
//

public enum AccessibilityAnalysisArea: String {
    
    // header
    case areaTab
    case labelIncome = "analysis_label_income"
    case labelExpense = "analysis_label_expenses"

    // budget carrousel
    case areaCard
    case labelSaving = "analysis_label_saving"
    case oval
    case lastMonth = "analysis_label_lastMonth"
    case labelBudget = "analysis_label_budget"
    case labelCreateBudget = "analysis_label_createBudget"
    case textCreateBudget = "analysis_text_createBudget"
    case btnBudgets
    
    // adjust budget popUop
    case labelPgBudget = "pg_label_budget"
    case toolTipSpend = "tooltip_text_totSpend"
    case icnSlectorFilter
    case adjuntBudgetButton = "Button"
    
    // timeline
    case areaDebt
    case areaMovement1
    case areaMovement2
    case areaMovement3
    case areaMovement4
    
    // recomendations
    case btnRecomendations
    
    // tricks Area
    case areaTricks
    case tricksTitle = "analysis_title_tricks"
    case tricktoSaveTitle = "toolbar_title_tricksToSave"
    
    // tricks items
    case analysisTraveTitlelLarge = "analysis_title_travelsLarge"
    case analysisTextTravelLarge = "analysis_text_travelsLarge"
    case analysisMonthlyExpenseLarge = "analysis_text_monthlyExpensesLarge"
    case icnMonthlyExpenses1
    case titleMontlyExpenseLarge = "analysis_title_monthlyExpensesLarge"
    
    // tricks items xpenses
    case btnExpenses
    case icnMonthlyExpenses
    case titleMonthlyExpense = "analysis_title_monthlyExpenses"
    
    // tricks items travels
    case btnTravel
    case icnTravels
    case titleTravel = "analysis_title_travels"
    
    // tricks items supermarket
    case btnSupermarket
    case icnSupermarket
    case titleSuperMarket = "analysis_title_supermarket"
    case icnTravels1

    // tricks items extraMoney
    case btnExtraMoney
    case icnExtraMoney
    case titleExtraMoney = "analysis_title_extraMoney"
    case icnSupermarket1
    case textSuperMarketLarge = "analysis_text_supermarketLarge"
    case titleSuperMarketLarge = "analysis_title_supermarketLarge"
    
    // tricks items excessive xpense
    case btnExcessiveExpenses
    case icnExtraMoney1
    case icnExcessiveExpenses
    case titleExtraMoneyLArge = "analysis_title_extraMoneyLarge"
    case titleexcessiveExpenses = "analysis_title_excessiveExpenses"
    case textExtraMoney = "analysis_text_extraMoneyLarge"
    
    // loader
    case loader1
    case txtKnow
    case txtAdvice
    case txtHelp
    case animation = "Bitmap"
    case popUpLoading = "generic_popup_loadingContent"
    
    // graph
    case dualBarGraph = "Rectangle"
    
    // Transfers
    case btnAll
    case btnDelivered
    case btnReceived
    case btnShipments
    case btnRequests
    
    // piggyBank
    case piggyBanner = "areaPiggyBanks"
    case piggyLeftImg = "imgPiggyBank02"
    case piggyTitle = "analysis_label_yourPiggy"
    case separator = "Line"
    
    // Balance
    case incomeSegment = "btnDeposit"
    case expenseSegment = "search_tab_expenses"
    case amountLabel = "amount"
    case movementTable = "areaMovements"
    case dateHeader = "generic_label_todayDate"
    
    // TimeLine Movement detail
    case timeLinedetail = "areaTicket"
}

public enum AccessibilityAnalysisAreaTimeSelector {
    public static let analysisLabelChosenTemporalView = "analysis_label_chosenTemporalView"
}
