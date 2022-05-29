import Foundation

public protocol DropdownElement {
    var name: String { get }
}

public protocol DropdownDelegate: AnyObject {
    func didSelectOption(element: DropdownElement)
}

/// Represents the direction the dropdown will display to.
public enum DropdownDirection {
    /// The dropdown will be displayed upwards.
    case upwards
    /// The dropdown will be displayed downwards.
    case downwards
    /// The dropdown will be displayed upwards. If there is no space for the dropdown, it will go downwards.
    case upElseDown
    /// The dropdown will be displayed downwards. If there is no space for the dropdown, it will go upwards.
    case downElseUp
}

/// Represents how much size the dropdown has when displayed.
public enum DropdownDisplayMode {
    /// The dropdown will grow a fixed amount of 4 selection cells.
    /// If less items, the dropdown will clip to the number of cells.
    case defaultSize
    /// The dropdown will grow a fixed amount of cellsCount selection cells.
    /// If less items, the dropdown will clip to the number of cells.
    case cellsSize(cellsCount: Int)
    /// The dropdown will grow to the bottom of the view with an inset.
    /// If less items, the dropdown will clip to the number of cells.
    case growToScreenBounds(inset: CGFloat)
}

public struct DropdownConfiguration<T: Equatable & DropdownElement> {
    let title: String
    let elements: [T]
    let direction: DropdownDirection
    let displayMode: DropdownDisplayMode
    let firstElementDefaultSelected: Bool?
    
    public init(title: String, elements: [T], direction: DropdownDirection = .downElseUp, displayMode: DropdownDisplayMode = .defaultSize, firstElementDefaultSelected: Bool? = true) {
        self.title = title
        self.elements = elements
        self.direction = direction
        self.displayMode = displayMode
        self.firstElementDefaultSelected = firstElementDefaultSelected
    }
}

public enum DropdownType {
    case trips
    case standardLisboa
}

public struct DropdownStyle {
    
    let backgroundColor: UIColor
    let titleColor: UIColor
    let valueColor: UIColor
    let separatorColor: UIColor
    let iconColor: UIColor
    let titleFont: UIFont
    let valueFont: UIFont
    let type: DropdownType
    
    public static func trips() -> DropdownStyle {
        return DropdownStyle(
            backgroundColor: UIColor.black.withAlphaComponent(0.35),
            titleColor: .white,
            valueColor: .white,
            separatorColor: .white,
            iconColor: .white,
            titleFont: UIFont.santander(family: .text, type: .regular, size: 12),
            valueFont: UIFont.santander(family: .text, type: .regular, size: 20),
            type: .trips
        )
    }
    
    public static func standardLisboa() -> DropdownStyle {
        return DropdownStyle(
            backgroundColor: .skyGray,
            titleColor: .grafite,
            valueColor: .lisboaGray,
            separatorColor: .mediumSkyGray,
            iconColor: .darkTorquoise,
            titleFont: UIFont.santander(family: .text, type: .regular, size: 12),
            valueFont: UIFont.santander(family: .text, type: .regular, size: 17),
            type: .standardLisboa
        )
    }
}
