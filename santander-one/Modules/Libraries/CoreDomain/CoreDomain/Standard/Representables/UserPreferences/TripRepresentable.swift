//
//  Trip.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//

public protocol TripRepresentable {
    var tripCountry: CountryRepresentable { get }
    var fromDate: Date { get }
    var toDate: Date { get }
    var currencies: String { get }
    var tripReason: TripReason { get }
    var description: String { get }
}
