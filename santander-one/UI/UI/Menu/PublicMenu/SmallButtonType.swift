import CoreFoundationLib

public struct SmallButtonType: SmallButtonTypeRepresentable {
    public var font: UIFont
    
    public static func defaultStyle() -> SmallButtonType {
        SmallButtonType(font: UIFont.santander(type: .light, size: 18))
    }
}
