import CoreDomain

public final class MockCarbonFootprintRepository: CarbonFootprintRepository {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getCarbonFootprintIdentificationToken(input: CarbonFootprintIdInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error> {
        let mockRepresentable = MockCarbonFootprintRepresentable(self.mockDataInjector)
        return .success(mockRepresentable)
    }
    
    public func getCarbonFootprintDataToken(input: CarbonFootprintDataInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error> {
        let mockRepresentable = MockCarbonFootprintRepresentable(self.mockDataInjector)
        return .success(mockRepresentable)
    }
}

class MockCarbonFootprintRepresentable: CarbonFootprintTokenRepresentable {
    var idToken: String? = ""
    init(_ mockDataInjector: MockDataInjector) {
        self.idToken = mockDataInjector.mockDataProvider.carbonFootprint.idToken.values.first
    }
}
