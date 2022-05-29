import UI
import CoreFoundationLib
import Foundation

struct CountryDropdownModel: Equatable, DropdownElement {
    let name: String
    let code: String
    
    init(country: CountryEntity) {
        self.name = country.name
        self.code = country.code
    }
    
    static func == (lhs: CountryDropdownModel, rhs: CountryDropdownModel) -> Bool {
        return lhs.code == rhs.code && lhs.name == rhs.name
    }
}
