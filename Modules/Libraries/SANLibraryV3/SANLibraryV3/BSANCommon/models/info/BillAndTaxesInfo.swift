import Foundation

public struct BillAndTaxesInfo: Codable {
    var paymentBillTaxesDTO: PaymentBillTaxesDTO?
    var billAndTaxesTokenDTO: BillAndTaxesTokenDTO?
    private var billAndTaxesCache: [String: BillListDTO] = [:]
    private var futureBillListCache: [String: AccountFutureBillListDTO] = [:]
    
    public func billAndTaxesCacheFor(_ key: String) -> BillListDTO? {
        return billAndTaxesCache[key]
    }
    
    public mutating func addToBillAndTaxesListCache(_ billList: BillListDTO, contract: String) {
        var storedBills = billAndTaxesCache[contract]?.bills ?? []
        billList.bills.forEach {
            if !storedBills.contains($0) {
                storedBills.append($0)
            }
        }
        billAndTaxesCache[contract] = BillListDTO(bills: storedBills, pagination: billList.pagination)
    }
    
    internal mutating func removeCache() {
        billAndTaxesCache = [:]
    }
    
    public func futureBillCacheFor(_ key: String) -> AccountFutureBillListDTO? {
        return futureBillListCache[key]
    }
    
    public mutating func addFutureBillsListCache(_ key: String, futureBillList: AccountFutureBillListDTO) {
        var allBills = [AccountFutureBillDTO]()
        if let storedTransactions = futureBillListCache[key] {
            allBills = storedTransactions.billList
        }
        allBills += futureBillList.billList
        futureBillListCache[key] = AccountFutureBillListDTO(billList: allBills, additionalInfo: futureBillList.additionalInfo)
    }
    
    public mutating func removeBillFutureList() {
        self.futureBillListCache = [:]
    }
}
