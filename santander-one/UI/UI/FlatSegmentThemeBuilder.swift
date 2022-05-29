//
//  File.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 19/05/2020.
//

public final class FlatSegmentedTheme {
    /// color for selected segment text
    public var selectedTextColor: UIColor = .black
    /// font for selected segment text
    public var selectedTextFont: UIFont = UIFont.boldSystemFont(ofSize: 12.0)
    /// font for selected segment text
    public var unSelectedTextFont: UIFont = UIFont.systemFont(ofSize: 12.0)
    /// color for unselected segment text
    public var unSelectedTextColor: UIColor = .gray
    /// background of the whole segment component
    public var backgroundColor: UIColor = .clear
    /// corner radious of the whole segment
    public var cornerRadious: CGFloat = 0.0
    /// border color of the whole segment
    public var borderColor: UIColor = .clear
    /// border width of the whole segment
    public var borderWidth: CGFloat = 0.0
}

/// group all properties to customize FlatSegmentedControl
public final class FlatSegmentThemeBuilder {
    
    private var themeComponents: FlatSegmentedTheme

    public init() {
        self.themeComponents = FlatSegmentedTheme()
    }
    
    /// color for sselected segment text
    public func setSelectedTextColor(_ color: UIColor) -> FlatSegmentThemeBuilder {
        themeComponents.selectedTextColor = color
        return self
    }
    /// color for unselected segment text
    public func setUnSelectedTextColor(_ color: UIColor) -> FlatSegmentThemeBuilder {
        themeComponents.unSelectedTextColor = color
        return self
    }
    /// background of the whole segment component
    public func setBackgroundColor(_ backgroundColor: UIColor) -> FlatSegmentThemeBuilder {
        themeComponents.backgroundColor = backgroundColor
        return self
    }
    /// corner radious of the whole segment
    public func setCornerRadious(_ cornerRadious: CGFloat) -> FlatSegmentThemeBuilder {
        themeComponents.cornerRadious = cornerRadious
        return self
    }
    /// border color of the whole segment
    public func setBorderColor(_ borderColor: UIColor) -> FlatSegmentThemeBuilder {
        themeComponents.borderColor = borderColor
        return self
    }
    /// border width of the whole segment
    public func setBorderWidth(_ borderWidth: CGFloat) -> FlatSegmentThemeBuilder {
        themeComponents.borderWidth = borderWidth
        return self
    }
    /// font for selected segment text
    public func setSelectedTextFont(_ font: UIFont) -> FlatSegmentThemeBuilder {
        themeComponents.selectedTextFont = font
        return self
    }
    /// font for unselected segment text
    public func setUnSelectedTextFont(_ font: UIFont) -> FlatSegmentThemeBuilder {
         themeComponents.unSelectedTextFont = font
         return self
     }
    public func build() -> FlatSegmentedTheme {
        return themeComponents
    }
}
