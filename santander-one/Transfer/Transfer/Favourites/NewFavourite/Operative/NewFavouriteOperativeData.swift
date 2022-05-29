import CoreFoundationLib
import CoreDomain

public protocol NewFavouriteOperativeData {
    var country: SepaCountryInfoEntity? { get set }
    var currency: SepaCurrencyInfoEntity? { get set }
    var sepaList: SepaInfoListEntity? { get set }
    var alias: String? { get set }
    var beneficiaryName: String? { get set }
    var favouriteList: [PayeeRepresentable]? { get }
    var iban: IBANEntity? { get set }
    var isNoSepa: Bool { get }
}
