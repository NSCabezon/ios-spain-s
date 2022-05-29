//
//  BizumNGOCollectionViewCellViewModel.swift
//  Bizum

import CoreFoundationLib

struct BizumNGOCollectionViewCellViewModel {
    let name: String
    let identifier: String
    let alias: String
    private let colorsByName: ColorsByNameViewModel
    private let baseUrl: String?
    
    init(name: String, identifier: String, alias: String, colorsByName: ColorsByNameViewModel, baseUrl: String?) {
        self.name = name
        self.identifier = identifier
        self.alias = alias
        self.colorsByName = colorsByName
        self.baseUrl = baseUrl
    }
    
    public var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    var avatarColor: UIColor {
        return self.colorsByName.color
    }
    
    var identifierFormatted: String {
        return self.identifier.replacingOccurrences(of: "+", with: "")
    }
    
    var iconUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@RWD/ongs/iconos/%@.png", baseUrl, self.identifierFormatted)
    }
}
