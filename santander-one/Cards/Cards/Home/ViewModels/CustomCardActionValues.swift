//
//  CustomCardActionValues.swift
//  Cards
//
//  Created by David Gálvez Alonso on 08/03/2021.
//

import CoreFoundationLib

final public class CustomCardActionValues {
    public let identifier: String
    public let location: String?
    public let localizedKey: String
    let icon: String
    let section: String
    public let isDisabled: (CardEntity) -> Bool
    
    public init(identifier: String, localizedKey: String, icon: String, section: String, location: String? = nil, isDisabled: @escaping (CardEntity) -> Bool) {
        self.identifier = identifier
        self.localizedKey = localizedKey
        self.icon = icon
        self.section = section
        self.location = location
        self.isDisabled = isDisabled
    }
}
