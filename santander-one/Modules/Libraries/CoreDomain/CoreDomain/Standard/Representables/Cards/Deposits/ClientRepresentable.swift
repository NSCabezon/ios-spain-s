public protocol ClientRepresentable {
    var personType: String? { get }
    var personCode: String? { get }
    var description: String { get }
}
