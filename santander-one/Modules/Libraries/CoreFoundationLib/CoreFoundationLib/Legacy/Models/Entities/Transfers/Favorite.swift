import CoreDomain
/// Protocol for Sepa and No Sepa favorite abstraction
public protocol FavoriteType {
    var name: String? { get set }
    var alias: String? { get }
    var account: String? { get }
    var countryCode: String? { get }
    var currencyCode: String? { get }
    var favorite: PayeeRepresentable { get }
    var isSepa: Bool { get }
    var noSepaPayeeDetail: NoSepaPayeeDetailEntity? { get }
}

extension FavoriteType {
    
    public var name: String? {
        return self.favorite.payeeName
    }
    
    public var currencyCode: String? {
        return self.favorite.currencySymbol
    }
    
    public var alias: String? {
        return self.favorite.payeeDisplayName
    }
}

public struct NoSepaFavoriteAdapter {
    public private(set) var favorite: PayeeRepresentable
    public let noSepaPayeeDetail: NoSepaPayeeDetailEntity?
    private var _name: String?
    
    public init(favorite: PayeeRepresentable, noSepaPayeeDetail: NoSepaPayeeDetailEntity? = nil) {
        self.favorite = favorite
        self.noSepaPayeeDetail = noSepaPayeeDetail
        _name = self.favorite.payeeName
    }
}

extension NoSepaFavoriteAdapter: FavoriteType {
    public var name: String? {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    public var isSepa: Bool {
        return false
    }
    
    public var account: String? {
        return self.favorite.formattedAccount
    }
    
    public var countryCode: String? {
        return self.noSepaPayeeDetail?.countryCode
    }
}

public struct SepaFavoriteAdapter {
    public private(set) var favorite: PayeeRepresentable
    private var _name: String?
    
    public init(favorite: PayeeRepresentable) {
        self.favorite = favorite
        _name = self.favorite.payeeName
    }
}

extension SepaFavoriteAdapter: FavoriteType {
    public var name: String? {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    public var isSepa: Bool {
        return true
    }
    
    public var account: String? {
        return self.favorite.ibanRepresentable?.formatted
    }
    
    public var countryCode: String? {
        return self.favorite.ibanRepresentable?.countryCode
    }
    
    public var noSepaPayeeDetail: NoSepaPayeeDetailEntity? {
        return nil
    }
}
