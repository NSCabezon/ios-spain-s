public protocol BigButtonTypeRepresentable {
    var font: UIFont { get }
    var lineBreakMode: NSLineBreakMode { get }
    var numberOfLines: Int { get }
    var minimumScaleFactor: CGFloat? { get }
}

public protocol SmallButtonTypeRepresentable {
    var font: UIFont { get }
}

