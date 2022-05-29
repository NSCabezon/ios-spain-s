//
//  OneFilterStyle.swift
//  UIOneComponents
//
//  Created by Carlos Monfort Gómez on 21/9/21.
//

import UIKit

public struct OneFilterStyle {
    let backgroundColor: UIColor
    let selectedColor: UIColor
    let unselectedColor: UIColor
    let oneCornerRadiusType: OneCornerRadiusType
    let oneShadowsType: OneShadowsType
    let segmentBorderColor: UIColor
    let segmentBorderWidth: CGFloat
    let selectedLabelAttributes: [NSAttributedString.Key: NSObject]
    let unselectedLabelAttributes: [NSAttributedString.Key: NSObject]

    public init(backgroundColor: UIColor,
                selectedColor: UIColor,
                unselectedColor: UIColor? = nil,
                oneCornerRadiusType: OneCornerRadiusType,
                oneShadowsType: OneShadowsType,
                segmentBorderColor: UIColor,
                segmentBorderWidth: CGFloat,
                selectedLabelAttributes: [NSAttributedString.Key: NSObject],
                unselectedLabelAttributes: [NSAttributedString.Key: NSObject]) {
        self.backgroundColor = backgroundColor
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor ?? backgroundColor
        self.oneCornerRadiusType = oneCornerRadiusType
        self.oneShadowsType = oneShadowsType
        self.segmentBorderColor = segmentBorderColor
        self.segmentBorderWidth = segmentBorderWidth
        self.selectedLabelAttributes = selectedLabelAttributes
        self.unselectedLabelAttributes = unselectedLabelAttributes
    }
    
    public static let defaultOneFilterStyle =
        OneFilterStyle(backgroundColor: .oneSkyGray,
                       selectedColor: .oneWhite,
                       oneCornerRadiusType: .oneShRadius8,
                       oneShadowsType: .oneShadowSmall,
                       segmentBorderColor: .oneSkyGray,
                       segmentBorderWidth: 4,
                       selectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.oneDarkTurquoise,
                                                 NSAttributedString.Key.font: UIFont.typography(fontName: .oneB300Bold)],
                       unselectedLabelAttributes: [NSAttributedString.Key.foregroundColor: UIColor.oneLisboaGray,
                                                   NSAttributedString.Key.font: UIFont.typography(fontName: .oneB300Regular)])
}
