import CoreFoundationLib

public struct BigButtonType: BigButtonTypeRepresentable {
    public var font: UIFont = UIFont.santander(type: .light, size: 19.0)
    public var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    public var numberOfLines: Int = 2
    public var minimumScaleFactor: CGFloat? = 0.45
    
    public init() {
        self.font = UIFont.santander(type: .regular, size: 20)
        self.lineBreakMode = .byTruncatingTail
        self.numberOfLines = 2
        self.minimumScaleFactor = nil
    }
    
    public init(
        font: UIFont,
        lineBreakMode: NSLineBreakMode,
        numberOfLines: Int,
        minimumScaleFactor: CGFloat?
    ) {
        self.font = font
        self.lineBreakMode = lineBreakMode
        self.numberOfLines = numberOfLines
        self.minimumScaleFactor = minimumScaleFactor
    }
    
    public func forPublicMenu() -> BigButtonType {
        BigButtonType(font: UIFont.santander(type: .light, size: 19.0),
                      lineBreakMode: .byTruncatingTail,
                      numberOfLines: 2,
                      minimumScaleFactor: 0.45)
    }
}
