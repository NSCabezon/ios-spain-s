import UIKit

public struct LisboaSegmentedControlStyle {
    let backgroundColor: UIColor
    let selectedColor: UIColor
    let unselectedColor: UIColor
    let border: BorderStyle
    let optionCornerRadius: CGFloat
    let selectedLabelAttributes: [NSAttributedString.Key: NSObject]
    let unselectedLabelAttributes: [NSAttributedString.Key: NSObject]
    let shadowColor = UIColor.black.cgColor
    let shadowRadius: CGFloat = 2
    let shadowOffSet = CGSize(width: 2.0, height: 0.0)
    let shadowOpacity: Float = 0.1
    let defaultShadowColor = UIColor.clear.cgColor
    let defaultShadowRadius: CGFloat = 0
    let defaultShadowOffSet = CGSize.zero
    let defaultShadowOpacity: Float = 0.0
    
    public struct BorderStyle {
        let cornerRadius: CGFloat
        let color: UIColor
        let width: CGFloat
    }

    public init(backgroundColor: UIColor,
                selectedColor: UIColor,
                unselectedColor: UIColor? = nil,
                border: BorderStyle,
                optionCornerRadius: CGFloat,
                selectedLabelAttributes: [NSAttributedString.Key: NSObject],
                unselectedLabelAttributes: [NSAttributedString.Key: NSObject]) {
        self.backgroundColor = backgroundColor
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor ?? backgroundColor
        self.border = border
        self.optionCornerRadius = optionCornerRadius
        self.selectedLabelAttributes = selectedLabelAttributes
        self.unselectedLabelAttributes = unselectedLabelAttributes
    }
    
    public static let defaultSegmentedControlStyle =
        LisboaSegmentedControlStyle(backgroundColor: .skyGray,
                                    selectedColor: .white,
                                    border: BorderStyle(cornerRadius: 10, color: .skyGray, width: 4),
                                    optionCornerRadius: 10,
                                    selectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.darkTorquoise,
                                                              NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 15)],
                                    unselectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.lisboaGray,
                                                                NSAttributedString.Key.font: UIFont.santander(family: .text, type: .regular, size: 15)])
    
    public static let tripModeSegmentedControlStyle =
        LisboaSegmentedControlStyle(backgroundColor: UIColor.black.withAlphaComponent(0.35),
                                    selectedColor: UIColor.black.withAlphaComponent(0.58),
                                    unselectedColor: .clear,
                                    border: BorderStyle(cornerRadius: 10, color: .brownGray, width: 2),
                                    optionCornerRadius: 10,
                                    selectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                              NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 15)],
                                    unselectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                NSAttributedString.Key.font: UIFont.santander(family: .text, type: .regular, size: 15)])
    
    public static let analysisHeaderSegmentedControlStyle =
        LisboaSegmentedControlStyle(backgroundColor: .skyGray,
                                    selectedColor: .skyGray,
                                    unselectedColor: .skyGray,
                                    border: BorderStyle(cornerRadius: 5, color: .skyGray, width: 2),
                                    optionCornerRadius: 0,
                                    selectedLabelAttributes: [.foregroundColor: UIColor.darkTorquoise,
                                                              .font: UIFont.santander(family: .text, type: .bold, size: 15)],
                                    unselectedLabelAttributes: [.foregroundColor: UIColor.lisboaGray,
                                                                .font: UIFont.santander(family: .text, type: .regular, size: 15)])
    
    public static let financingSegmentedControlStyle =
        LisboaSegmentedControlStyle(backgroundColor: .mediumSkyGray,
                                    selectedColor: .white,
                                    border: BorderStyle(cornerRadius: 5, color: .mediumSkyGray, width: 4),
                                    optionCornerRadius: 10,
                                    selectedLabelAttributes: [.foregroundColor: UIColor.darkTorquoise,
                                                              .font: UIFont.santander(family: .text, type: .bold, size: 15)],
                                    unselectedLabelAttributes: [.foregroundColor: UIColor.lisboaGray,
                                                                .font: UIFont.santander(family: .text, type: .regular, size: 15)])
    
    public static let lightGraySegmentedControlStyle =
        LisboaSegmentedControlStyle(backgroundColor: .veryLightGray,
                                    selectedColor: .white,
                                    border: BorderStyle(cornerRadius: 10, color: .veryLightGray, width: 4),
                                    optionCornerRadius: 10,
                                    selectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.lisboaGray,
                                                              NSAttributedString.Key.font: UIFont.santander(family: .text, type: .bold, size: 14)],
                                    unselectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.lisboaGray,
                                                                NSAttributedString.Key.font: UIFont.santander(family: .text, type: .regular, size: 14)])
}
