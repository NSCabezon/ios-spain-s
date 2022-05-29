import SANLegacyLibrary
import CoreFoundationLib

class GlobalPositionPrefsMerger {
    let bsanManagersProvider: BSANManagersProvider
    let appRepository: AppRepository
    let accountDescriptorRepository: AccountDescriptorRepository
    let appConfigRepository: AppConfigRepository
    var globalPositionWrapper: GlobalPositionWrapper?
    var oldUserPref: UserPref?
        
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
    }
}

extension GlobalPositionPrefsMerger {
    func merge() throws -> Self {
        guard let globalPositionWrapper = try GlobalPositionWrapperFactory.getWrapper(bsanManagersProvider: bsanManagersProvider,
                                                                                      appRepository: appRepository,
                                                                                      accountDescriptorRepository: accountDescriptorRepository,
                                                                                      appConfigRepository: appConfigRepository) else {
                                                                                        return self
        }
        let userId = globalPositionWrapper.userId
        var oldUserPref: UserPref?
        if let userPrefDTO = try appRepository.getUserPrefDTO(userId: userId).getResponseData() {
            oldUserPref = update(oldUserPref: UserPref.from(dto: userPrefDTO), with: globalPositionWrapper)
        }
        self.globalPositionWrapper = globalPositionWrapper
        self.oldUserPref = oldUserPref
        
        return self
    }
    
    private func update(oldUserPref: UserPref, with globalPosition: GlobalPositionWrapper) -> UserPref {
        func update<P: GenericProduct>(products: GenericProductList<P>, andUserPrefs box: inout PGBoxDTO) {
            let boxCopy = box
            box.removeAllItems()
            var lastIndex = -1
            products.list.forEach {
                guard let relatedItem = boxCopy.getItem(withIdentifier: $0.productIdentifier) else {
                    return
                }
                $0.setVisible(relatedItem.isVisible)
                $0.setPositionInList(relatedItem.order)
                box.set(item: relatedItem, withIdentifier: $0.productIdentifier)
                if lastIndex < relatedItem.order {
                    lastIndex = relatedItem.order
                }
            }
            products.list.forEach {
                guard boxCopy.getItem(withIdentifier: $0.productIdentifier) == nil else {
                    return
                }
                let boxItem = PGBoxItemDTO(order: lastIndex, isVisible: true)
                lastIndex += 1
                $0.setPositionInList(boxItem.order)
                box.set(item: boxItem, withIdentifier: $0.productIdentifier)
            }
        }
        update(products: globalPosition.accounts, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.accountsBox)
        update(products: globalPosition.cards, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.cardsBox)
        update(products: globalPosition.stockAccounts, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.stocksBox)
        update(products: globalPosition.deposits, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.depositsBox)
        update(products: globalPosition.loans, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.loansBox)
        update(products: globalPosition.notManagedRVStockAccounts, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.portfolioNotManagedVariableIncomesBox)
        update(products: globalPosition.managedRVStockAccounts, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.portfolioManagedVariableIncomesBox)
        update(products: globalPosition.notManagedPortfolios, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox)
        update(products: globalPosition.managedPortfolios, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.portfolioManagedsBox)
        update(products: globalPosition.pensions, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.pensionssBox)
        update(products: globalPosition.funds, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.fundssBox)
        update(products: globalPosition.insuranceSavings, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.insuranceSavingsBox)
        update(products: globalPosition.insuranceProtection, andUserPrefs: &oldUserPref.userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox)
        return oldUserPref
    }
}
