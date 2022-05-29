//
//  CarbonFootprintRepository.swift
//  CoreFoundationLib
//
//  Created by Johnatan Zavaleta on 28/02/22.
//

public protocol CarbonFootprintRepository {
    func getCarbonFootprintIdentificationToken(input: CarbonFootprintIdInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error>
    func getCarbonFootprintDataToken(input: CarbonFootprintDataInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error>
}
