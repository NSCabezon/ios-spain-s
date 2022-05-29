import CoreFoundationLib

public final class PullOffersInterpreterMock {
    public init() {}
}
    
    
extension PullOffersInterpreterMock: PullOffersInterpreter, PfmHelperProtocol {
    
    public func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        return []
    }
    
    public func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        return []
    }
    
    public func disableOffer(identifier id: String?) {
        
    }
    
    public func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity, searchText: String) -> [CardTransactionEntity] {
        return []
    }
    
    public func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String) -> [AccountTransactionEntity] {
        return [AccountTransactionEntity]()
    }
    
    public func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        return []
    }
    
    public func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        return []
    }
    
    public func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        return 0
    }
    
    public func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        return 0
    }
    
    public func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        return AmountEntity(value: 0)
    }
    
    public func setReadMovements(for userId: String, account: AccountEntity) {
        
    }
    
    public func setReadMovements(for userId: String, card: CardEntity) {
        
    }
    
    public func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    public func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    public func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return OfferDTO(product: OfferProductDTO(identifier: "",
                                                 neverExpires: true,
                                                 transparentClosure: true,
                                                 description: "",
                                                 rulesIds: [],
                                                 iterations: 3,
                                                 banners: [],
                                                 bannersContract: [],
                                                 action: nil,
                                                 startDateUTC: nil,
                                                 endDateUTC: nil))
    }
    
    public func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    public func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    public func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {
        
    }
    
    public func expireOffer(userId: String, offerDTO: OfferDTO) {
        
    }
    
    public func removeOffer(location: String) {
        
    }
    
    public func reset() {
        
    }
    
    public func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
    
    public func execute() {
    }
    
    public func finishSession(_ reason: SessionFinishedReason?) {
    }
}
