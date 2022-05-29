//
//  InsurancesRepository.swift
//  CoreFoundationLib
//
//  Created by Pedro Meira on 17/08/2021.
//

public protocol InsurancesRepository {
    func updateInsuranceAlias(insuranceRepresentable: InsuranceRepresentable, newAlias: String) -> Result<Void, Error>
}
