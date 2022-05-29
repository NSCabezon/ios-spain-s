//

import Foundation

// MARK: - Account Handler
enum AccountOptionsHandler {
    
    enum AccountOptionIndex {
        static let transferIndex = 0
        static let moneyPlanIndex = 1
        static let billsTaxIndex = 2
        static let detailIndex = 3
        static let foreignExchangeIndex = 4
        static let purchaseAccountIndex = 5
    }
    
    static func buildTransfer(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("accountOption_button_transfer"), "icnTransfers", AccountOptionsHandler.AccountOptionIndex.transferIndex)
    }
    
    static func buildMoneyPlan(_ dependencies: PresentationComponent) -> ProductOption {
        
        return (dependencies.stringLoader.getString("accountOption_button_moneyPlan"), "icnEvolucion", AccountOptionsHandler.AccountOptionIndex.moneyPlanIndex)
    }
    
    static func buildBillsTaxs(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("accountOption_button_billsTaxs"), "icnReceipts", AccountOptionsHandler.AccountOptionIndex.billsTaxIndex)
    }
    
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("accountOption_button_detail"), "icnInfoRed", AccountOptionsHandler.AccountOptionIndex.detailIndex)
    }
    
    static func buildForeignExchange(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("location_accountOption_label_foreignExchange"), "icnForeignCurrency", AccountOptionsHandler.AccountOptionIndex.foreignExchangeIndex)
    }
    
    static func buildPurchaseAccount(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("cardsOption_button_contractAccounts"), "icnContractMenuRed", AccountOptionsHandler.AccountOptionIndex.purchaseAccountIndex)
    }
}

// MARK: - Loan Handler
enum LoanOptionsHandler {
    
    enum LoanOptionIndex {
        static let parcialAmortization = 0
        static let changeAccount = 1
        static let detail = 2
        static let purchaseLoan = 3
    }
    static func buildParcialAmortization(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("loansOption_button_anticipatedAmortization"), "icnParcialAmortization", LoanOptionIndex.parcialAmortization)
    }
    
    static func buildChangeAccount(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("loansOption_button_changeAccount"), "icnChangeSccount", LoanOptionIndex.changeAccount)
    }
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", LoanOptionIndex.detail)
    }
    static func buildPurchaseLoan(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("cardsOption_button_contractLoans"), "icnContractMenuRed", LoanOptionIndex.purchaseLoan)
    }
}

// MARK: - Fund Handler
enum FundOptionsHandler {
    
    enum FundOptionIndex {
        static let subscription = 0
        static let transfer = 1
        static let detail = 2
        static let purchaseFund = 3
    }
    static func buildSubscription(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("fundsOption_button_subscription"), "icnSuscription", FundOptionIndex.subscription)
    }
    static func buildTransfer(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("fundsOption_button_transfer"), "icnTransfer_simple", FundOptionIndex.transfer)
    }
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", FundOptionIndex.detail)
    }
    static func buildPurchaseFund(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("fundsOption_button_fundsSearch"), "icnFundsSearch", FundOptionIndex.purchaseFund)
    }
}

// MARK: - Deposit Handler
enum DepositOptionsHandler {
    enum DepositOptionIndex {
        static let detail = 0
        static let purchaseDeposit = 1
    }
    
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", DepositOptionIndex.detail)
    }
    static func buildPurchaseDeposit(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("cardsOption_button_contractDeposits"), "icnContractMenuRed", DepositOptionIndex.purchaseDeposit)
    }
}

// MARK: - Pension Handler
enum PensionOptionsHandler {
    enum PensionOptionIndex {
        static let extraInput = 0
        static let periodicInput = 1
        static let detail = 2
        static let purchasePension = 3
    }
    static func buildExtraInput(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("plansOption_button_extraContribution"), "icnExtraInput", PensionOptionIndex.extraInput)
    }
    static func buildPeriodicInput(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("plansOption_button_periodicContribution"), "icnPeriodicInput", PensionOptionIndex.periodicInput)
    }
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", PensionOptionIndex.detail)
    }
    static func buildPurchasePension(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("plansOption_button_plansSearch"), "icnPlansSearch", PensionOptionIndex.purchasePension)
    }
 }

// MARK: - Account Handler
enum StockOptionsHandler {
    
    enum StockOptionIndex {
        static let allStocksIndex = 0
        static let searchStocksIndex = 1
        static let brokerIndex = 2
        static let alertsIndex = 3
    }
    
    static func buildAllStocks(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("stocksOption_button_order"), "icnArrowLeftRedRetail", StockOptionsHandler.StockOptionIndex.allStocksIndex)
    }
    
    static func buildSearchStocks(_ dependencies: PresentationComponent) -> ProductOption {
        
        return (dependencies.stringLoader.getString("stocksOption_button_search"), "icnSearchRed", StockOptionsHandler.StockOptionIndex.searchStocksIndex)
    }
    
    static func buildBroker(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("stocksOption_button_broker"), "icnBroker", StockOptionsHandler.StockOptionIndex.brokerIndex)
    }
    
    static func buildAlerts(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("stocksOption_button_settingAlerts"), "icnBell", StockOptionsHandler.StockOptionIndex.alertsIndex)
    }
    
}

// MARK: - Product Profile Transaction Handler
enum ProductProfileTransactionOptionsHandler {
    
    enum ProductProfileTransactionOptionIndex {
        static let detail = 0
    }

    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", ProductProfileTransactionOptionIndex.detail)
    }
}

// MARK: - Imposition Profile options handler
enum ImpositionOptionsHandler {
    enum ImpositionOptionsIndex {
        static let detail = 0
        static let liquidations = 1
    }
    
    static func buildDetail(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("productOption_button_detail"), "icnInfoRed", ImpositionOptionsIndex.detail)
    }
    
    static func buildLiquidations(_ dependencies: PresentationComponent) -> ProductOption {
        return (dependencies.stringLoader.getString("toolbar_title_settlements"), "icnArrowLeftRedRetail", ImpositionOptionsIndex.liquidations)
    }
}

// MARK: - Insurance Handler
enum InsuranceOptionsHandler {
    
    // Protection
    enum InsuranceProtectionOptionIndex {
        static let policyGestion = 0
    }
    
    static func buildPolicyGestion(_ dependencies: PresentationComponent, with string: String? = nil) -> ProductOption {
        return (dependencies.stringLoader.getString(string ?? "productOption_button_detail"), "settingInsurance", InsuranceProtectionOptionIndex.policyGestion)
    }
    
    // Saving
    enum InsuranceSavingOptionIndex {
        static let extraAportation = 0
        static let aportationPlanChange = 1
        static let activatePlan = 2
    }
    
    static func extraAportation(_ dependencies: PresentationComponent, with string: String? = nil) -> ProductOption {
        return (dependencies.stringLoader.getString(string ?? "productOption_button_detail"), "aportacionSeguroIcon", InsuranceSavingOptionIndex.extraAportation)
    }
    
    static func aportationPlanChange(_ dependencies: PresentationComponent, with string: String? = nil) -> ProductOption {
        return (dependencies.stringLoader.getString(string ?? "productOption_button_detail"), "activarPlanAportacionesIcon", InsuranceSavingOptionIndex.aportationPlanChange)
    }
    
    static func activatePlan(_ dependencies: PresentationComponent, with string: String? = nil) -> ProductOption {
        return (dependencies.stringLoader.getString(string ?? "productOption_button_detail"), "icnChangeRemittance", InsuranceSavingOptionIndex.activatePlan)
    }
}
