public protocol SelectOptionButtonModelRepresentable {
    var titleKey: String { get }
    var action: PublicMenuAction { get set }
    var node: KindOfPublicMenuNode { get }
    var event: String { get }
}
