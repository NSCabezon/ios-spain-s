import CoreDomain

public protocol SpainCarbonFootprintRepository: CarbonFootprintRepository {
    func getCarbonFootprintIdentificationToken(input: CarbonFootprintIdInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error>
    func getCarbonFootprintDataToken(input: CarbonFootprintDataInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error>
}
