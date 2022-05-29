//
//  Fonts.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import UIKit

public enum FontType {
    
    case regular
    case medium
    case bold
    case boldItalic
    case light
    case italic
    case semibold
    
    case black
    case blackItalic
    case heavy
    case heavyItalic
    case semiboldItalic
    case mediumItalic
    case lightItalic
    case thin
    case thinItalic
    case hairline
    case hairlineItalic
    case extrabold
    case extraboldItalic

    public var description: String {
        switch self {
        case .medium:
            return "Medium"
        case .regular:
            return "Regular"
        case .bold:
            return "Bold"
        case .light:
            return "Light"
        case .boldItalic:
            return "BoldItalic"
        case .italic:
            return "Italic"
        case .semibold:
            return "Semibold"
        case .black:
            return "Black"
        case .blackItalic:
            return "BlackItalic"
        case .heavy:
            return "Heavy"
        case .heavyItalic:
            return "HeavyItalic"
        case .semiboldItalic:
            return "SemiboldItalic"
        case .mediumItalic:
            return "MediumItalic"
        case .lightItalic:
            return "LightItalic"
        case .thin:
            return "Thin"
        case .thinItalic:
            return "ThinItalic"
        case .hairline:
            return "Hairline"
        case .hairlineItalic:
            return "HairlineItalic"
        case .extrabold:
            return "Extrabold"
        case .extraboldItalic:
            return "ExtraboldItalic"
        }
    }
    
    public var cyrillicLatoDescription: String {
        switch self {
        case .medium:
            return "Regular"
        case .regular:
            return "Regular"
        case .bold:
            return "Bold"
        case .light:
            return "Light"
        case .boldItalic:
            return "BoldItalic"
        case .italic:
            return "Italic"
        case .semibold:
            return "Semibold"
        case .black:
            return "Extrabold"
        case .blackItalic:
            return "ExtraboldItalic"
        case .heavy:
            return "Extrabold"
        case .heavyItalic:
            return "ExtraboldItalic"
        case .semiboldItalic:
            return "SemiboldItalic"
        case .mediumItalic:
            return "Italic"
        case .lightItalic:
            return "LightItalic"
        case .thin:
            return "Light"
        case .thinItalic:
            return "LightItalic"
        case .hairline:
            return "Light"
        case .hairlineItalic:
            return "LightItalic"
        case .extrabold:
            return "Extrabold"
        case .extraboldItalic:
            return "ExtraboldItalic"
        }
    }
}

public enum FontFamily {
    
    case headline
    case text
    case lato
    case micro
    case openSans
    
    public var description: String {
        switch self {
        case .headline:
            return "SantanderHeadline"
        case .text:
            return "SantanderText"
        case .lato:
            return "Lato"
        case .micro:
            return "SantanderMicroText"
        case .openSans:
            return "OpenSans"
        }
    }
}
