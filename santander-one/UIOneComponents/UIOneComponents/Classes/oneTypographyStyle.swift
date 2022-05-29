//
//  NewFonts.swift
//  UI
//
//  Created by Adrian Escriche Martín on 12/8/21.
//

import UIKit
import CoreFoundationLib

struct FontValue {
    let family: FontFamily
    let size: CGFloat
    let lineHeight: CGFloat
    let fontWeight: FontType
}

public enum FontName {
    case oneH600Bold
    case oneH600Regular
    case oneH600Light
    case oneH500Bold
    case oneH500Regular
    case oneH500Light
    case oneH400Bold
    case oneH400Regular
    case oneH400Light
    case oneH300Bold
    case oneH300Regular
    case oneH200Bold
    case oneH200Regular
    case oneH100Bold
    case oneH100Regular
    case oneB400Bold
    case oneB400Regular
    case oneB300Bold
    case oneB300Regular
    case oneB200Bold
    case oneB200Regular
    case oneB100Bold
    case oneB100Regular
    
   var fontValue: FontValue{
        switch self {
        case .oneH600Bold:
            return FontValue(family: FontFamily.headline, size: 58, lineHeight: 64, fontWeight: FontType.bold)
        case .oneH600Regular:
            return FontValue(family: FontFamily.headline, size: 58, lineHeight: 64, fontWeight: FontType.regular)
        case .oneH600Light:
            return FontValue(family: FontFamily.text, size: 58, lineHeight: 58, fontWeight: FontType.light)
        case .oneH500Bold:
            return FontValue(family: FontFamily.headline, size: 32, lineHeight: 40, fontWeight: FontType.bold)
        case .oneH500Regular:
            return FontValue(family: FontFamily.headline, size: 32, lineHeight: 40, fontWeight: FontType.regular)
        case .oneH500Light:
            return FontValue(family: FontFamily.text, size: 32, lineHeight: 40, fontWeight: FontType.light)
        case .oneH400Bold:
            return FontValue(family: FontFamily.headline, size: 28, lineHeight: 36, fontWeight: FontType.bold)
        case .oneH400Regular:
            return FontValue(family: FontFamily.headline, size: 28, lineHeight: 36, fontWeight: FontType.regular)
        case .oneH400Light:
            return FontValue(family: FontFamily.text, size: 28, lineHeight: 36, fontWeight: FontType.light)
        case .oneH300Bold:
            return FontValue(family: FontFamily.headline, size: 24, lineHeight: 28, fontWeight: FontType.bold)
        case .oneH300Regular:
            return FontValue(family: FontFamily.headline, size: 24, lineHeight: 28, fontWeight: FontType.regular)
        case .oneH200Bold:
            return FontValue(family: FontFamily.headline, size: 20, lineHeight: 24, fontWeight: FontType.bold)
        case .oneH200Regular:
            return FontValue(family: FontFamily.headline, size: 20, lineHeight: 24, fontWeight: FontType.regular)
        case .oneH100Bold:
            return FontValue(family: FontFamily.headline, size: 18, lineHeight: 24, fontWeight: FontType.bold)
        case .oneH100Regular:
            return FontValue(family: FontFamily.text, size: 18, lineHeight: 24, fontWeight: FontType.regular)
        case .oneB400Bold:
            return FontValue(family: FontFamily.micro, size: 16, lineHeight: 24, fontWeight: FontType.bold)
        case .oneB400Regular:
            return FontValue(family: FontFamily.micro, size: 16, lineHeight: 24, fontWeight: FontType.regular)
        case .oneB300Bold:
            return FontValue(family: FontFamily.micro, size: 14, lineHeight: 20, fontWeight: FontType.bold)
        case .oneB300Regular:
            return FontValue(family: FontFamily.micro, size: 14, lineHeight: 20, fontWeight: FontType.regular)
        case .oneB200Bold:
            return FontValue(family: FontFamily.micro, size: 12, lineHeight: 16, fontWeight: FontType.bold)
        case .oneB200Regular:
            return FontValue(family: FontFamily.micro, size: 12, lineHeight: 16, fontWeight: FontType.regular)
        case .oneB100Bold:
            return FontValue(family: FontFamily.micro, size: 10, lineHeight: 12, fontWeight: FontType.bold)
        case .oneB100Regular:
            return FontValue(family: FontFamily.micro, size: 10, lineHeight: 12, fontWeight: FontType.regular)
    }
  }
}

extension UIFont{
    public static func typography(fontName: FontName) -> UIFont {
        return FontsHandler.shared.santander(family: fontName.fontValue.family, type: fontName.fontValue.fontWeight, size: fontName.fontValue.size)
    }
}
