//
//  ChartSectorData.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 01/09/2020.
//

import Foundation
import CoreFoundationLib

// Data needed to buildUp a sector.
public struct ChartSectorData {
    /// amount of value representing the sector, expressed in percent
    public var value: Double
    /// rawValue repesented by the sector
    public var rawValue: Decimal = 0.0
    /// icon to be used for the sector
    public var iconName: String
    /// category name
    public var category: String
    /// category name to be displayed
    public var categoryAtttributtedText: NSAttributedString = NSAttributedString(string: "")
    public var categoryAtttributtedTextValue: NSAttributedString = NSAttributedString(string: "")
    /// sector and text fill color
    public var colors: Colors
    /// Image for icon 
    public var icon: UIImage? {
        Assets.image(named: iconName)
    }
    
    public init(value: Double, iconName: String, colors: Colors, category: String = "", rawValue: Decimal = 0.0) {
        self.value = value
        self.iconName = iconName
        self.colors = colors
        self.category = category
        self.rawValue = rawValue
    }
    
    /// wrap up color information for the sector
    public struct Colors {
        /// sector fill color
        public var sector: UIColor
        /// value text color
        public var textColor: UIColor
        
        public init(sector: UIColor, textColor: UIColor) {
            self.sector = sector
            self.textColor = textColor
        }
    }
}
