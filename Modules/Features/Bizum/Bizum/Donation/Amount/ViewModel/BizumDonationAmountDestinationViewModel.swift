import CoreFoundationLib

struct BizumDonationAmountDestinationViewModel: BizumNGOProtocol {
    var name: String
    var alias: String
    var identifier: String
    private let baseUrl: String?
    private let colorsByNameViewModel: ColorsByNameViewModel?
    
    init(name: String, alias: String, identifier: String, baseUrl: String?, colorsByNameViewModel: ColorsByNameViewModel? = nil) {
        self.name = name
        self.alias = alias
        self.identifier = identifier
        self.baseUrl = baseUrl
        self.colorsByNameViewModel = colorsByNameViewModel
    }
    
    var avatarColor: UIColor {
        return self.colorsByNameViewModel?.color ?? UIColor()
    }
    
    var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    private var identifierFormatted: String {
        return self.identifier.replacingOccurrences(of: "+", with: "")
    }
    
    var iconUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@RWD/ongs/iconos/%@.png", baseUrl, self.identifierFormatted)
    }
}
