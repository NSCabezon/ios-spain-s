import CoreDomain

public struct SignatureDTO: Codable {
    public var length: Int?
    public var positions: [Int]?
    public var values: [String]?

    public init() {
    }

    public init(length: Int, positions: [Int]) {
        self.length = length
        self.positions = positions
    }
}

extension SignatureDTO: SignatureRepresentable {}

extension SignatureDTO: SCARepresentable {
    public var type: SCARepresentableType {
        return .signature(self)
    }
}
