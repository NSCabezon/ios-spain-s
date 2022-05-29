//
//  ConfirmationOrganizationDetailViewModel.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 22/02/2021.
//

import Foundation
import CoreFoundationLib

struct ConfirmationOrganizationDetailViewModel {
    let name: String
    private let identifier: String
    private var colorsByNameViewModel: ColorsByNameViewModel?
    private let baseUrl: String?
    
    init(name: String, identifier: String, baseUrl: String?, colorsByNameViewModel: ColorsByNameViewModel? = nil) {
        self.name = name
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
