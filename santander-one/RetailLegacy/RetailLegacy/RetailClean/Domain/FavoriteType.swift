/// Protocol for Sepa and No Sepa favorite abstraction
protocol FavoriteType {
    var name: String? { get }
    var alias: String? { get }
    var account: String? { get }
    var countryCode: String? { get }
    var currencyCode: String? { get }
    var favorite: Favourite { get }
    var isSepa: Bool { get }
    var noSepaPayee: NoSepaPayee? { get }
}

extension FavoriteType {
    
    var name: String? {
        return favorite.baoName
    }
    
    var currencyCode: String? {
        return favorite.amount?.currency?.currencyName
    }
    
    var alias: String? {
        return favorite.alias
    }
}

struct NoSepaFavoriteAdapter {
    
    private(set) var favorite: Favourite
    let noSepaPayee: NoSepaPayee?
    
    init(favorite: Favourite, noSepaPayee: NoSepaPayee? = nil) {
        self.favorite = favorite
        self.noSepaPayee = noSepaPayee
    }
}

extension NoSepaFavoriteAdapter: FavoriteType {
    
    var isSepa: Bool {
        return false
    }
    
    var account: String? {
        return favorite.formattedAccount
    }
    
    var countryCode: String? {
        return (self.noSepaPayee?.bankCountryCode?.isEmpty == false) ? self.noSepaPayee?.bankCountryCode: self.noSepaPayee?.countryCode
    }
}

struct SepaFavoriteAdapter {
    
    private(set) var favorite: Favourite
    
    init(favorite: Favourite) {
        self.favorite = favorite
    }
}

extension SepaFavoriteAdapter: FavoriteType {
    
    var isSepa: Bool {
        return true
    }
    
    var account: String? {
        return favorite.iban?.formatted
    }
    
    var countryCode: String? {
        return favorite.iban?.countryCode
    }
    
    var noSepaPayee: NoSepaPayee? {
        return nil
    }
}
