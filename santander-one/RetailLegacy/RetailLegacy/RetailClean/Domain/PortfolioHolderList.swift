import CoreDomain
import SANLegacyLibrary

class PortfolioHolderList {
    private(set) var holders: [HolderDTO]?
    
    init(_ holders: [HolderDTO]) {
        self.holders = holders
    }
    
    func getFirstHolder() -> String? {
        return holders?.first?.name
    }
    
    func getNumberOfHolders() -> Int? {
        guard let holders = self.holders else { return nil }
        
        let ownerHolder = holders.filter {
            $0.ownershipTypeDesc?.rawValue == OwnershipTypeDesc.holder.rawValue ||
            $0.ownershipTypeDesc?.rawValue == OwnershipTypeDesc.owner.rawValue
        }
        return ownerHolder.count
    }
}
