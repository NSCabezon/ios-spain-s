import SANLegacyLibrary

public class MockDataInjector {
    public private(set) var mockDataProvider: MockDataProvider
    
    public init(mockDataProvider: MockDataProvider = MockDataProvider()) {
        self.mockDataProvider = mockDataProvider
    }
    
    public func register<T>(for keypath: WritableKeyPath<MockDataProvider, T>, element: T) {
        mockDataProvider[keyPath: keypath] = element
    }
    
    public func register<T: Decodable>(for keypath: WritableKeyPath<MockDataProvider, T>, filename: String) {
        mockDataProvider[keyPath: keypath] = loadFromFile(filename)
    }
}

public extension MockDataInjector {
    func loadFromFile<T: Decodable>(_ filename: String) -> T {
        guard let filepath = Bundle(for: MockDataInjector.self).path(forResource: filename, ofType: "json"),
              let stringToParse = try? String(contentsOfFile: filepath),
              let data = stringToParse.data(using: .utf8)
        else { fatalError() }
        do {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            decoder.dateDecodingStrategy = .formatted(formatter)
            return try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            fatalError()
        }
    }
}
