public protocol PGBoxRepresentable {
    var order: Int { get }
    var isOpen: Bool { get }
    var productsRepresentable: [String: PGBoxItemRepresentable] { get }
}
