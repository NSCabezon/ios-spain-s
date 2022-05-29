class PortfolioManagedVariableIncomeModelViewHeader: ProductBaseModelViewHeader<ProductGenericViewHeader> {
    
    override func getProductNumber() -> LocalizedStylableText {
        return stringLoader.getString("pgBasket_title_portfolioManaged")
    }
    
    override func getTotalAmount() -> String? {
        return try? globalPosition.managedRVStockAccounts.getTotalAmount(filter, globalPosition.globalPositionConfig.enableCounterValue ?? false).getFormattedAmountUIWith1M()
    }
    
    override func getSubLabel() -> LocalizedStylableText {
        return stringLoader.getString("pgBasket_label_totInvestiment")
    }
    
    override func isSectionOpen() -> Bool? {
        return userPref?.isPortfolioManagedVariableIncomeBoxOpen()
    }
    
    override func didTapHeader() {
        guard let userPref = userPref else { return }
        
        if let open = isSectionOpen() {
            userPref.userPrefDTO.pgUserPrefDTO.portfolioManagedVariableIncomesBox.isOpen = !open
        }
        
        updatePref(userPref: userPref)
        
        if let mDelegate = mDelegate, let section = section {
            mDelegate.onTableModelViewHeaderSelected(section: section)
        }
    }
}
