//
//  ServiceNames.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 16/04/2021.
//

struct ServiceIdentifier {
    static let salesforce = "SALESFORCE"
    static let twinpush = "TWINPUSH"
}

enum NotificationType {
    case twinpush
    case salesforce
}
