//
//  Styles.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import Foundation
import UI

enum FontType {
    case regular
    case bold
    case boldItalic
    case light
}

extension UIFont {
    
    static func santanderHeadline(type: FontType = .regular, with size: CGFloat) -> UIFont {
        switch type {
        case .bold:
            return .santander(family: .headline, type: .bold, size: size)
        case .boldItalic:
            return .santander(family: .headline, type: .boldItalic, size: size)
        case .light:
            return .santander(family: .headline, type: .light, size: size)
        case .regular:
            return .santander(family: .headline, type: .regular, size: size)
        }
    }
    
    static func santanderText(type: FontType = .regular, with size: CGFloat) -> UIFont {
        switch type {
        case .bold:
            return .santander(family: .text, type: .bold, size: size)
        case .boldItalic:
            return .santander(family: .text, type: .boldItalic, size: size)
        case .light:
            return .santander(family: .text, type: .light, size: size)
        case .regular:
            return .santander(family: .text, type: .regular, size: size)
        }
    }
}

extension UIColor {
    
    // MARK: - Custom application colors
    
    static var paleSkyBlue: UIColor {
        return .mediumSky
    }
    
    static var sanRed: UIColor {
        return .santanderRed
    }
    
    static var greyishBrown: UIColor {
        return .sanGreyDark
    }
    
    static var brownishGrey: UIColor {
        return .mediumSanGray
    }
    
    static var lightGreyBlue: UIColor {
        return .darkSkyBlue
    }
    
    static var veryLightBlue: UIColor {
        return .lightSkyBlue
    }
    
    static var iceBlue: UIColor {
        return UIColor(red: 239.0 / 255.0, green: 246.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
    }
    
    static var topaz: UIColor {
        return .turquoise
    }
    
    static var blueGreen: UIColor {
        return .darkTorquoise
    }
    
    static var blueGraphic: UIColor {
        return UIColor(red: 32.0 / 255.0, green: 177.0 / 255.0, blue: 186.0 / 255.0, alpha: 1.0)
    }
    
    static var midBlue: UIColor {
        return UIColor(red: 37.0 / 255.0, green: 127.0 / 255.0, blue: 164.0 / 255.0, alpha: 1.0)
    }
    
    static var lightBlue: UIColor {
        return UIColor(red: 232.0 / 255.0, green: 241.0 / 255.0, blue: 245.0 / 255.0, alpha: 1.0)
    }
    
    static var sky30: UIColor {
        return UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }
    
    static var mediumSanGray: UIColor {
        return UIColor(red: 118.0 / 255.0, green: 118.0 / 255.0, blue: 118.0 / 255.0, alpha: 1.0)
    }
    
    static var mediumSkyGray: UIColor {
        return UIColor(red: 219.0 / 255.0, green: 224.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0)
    }
    
    static var LightSanGray: UIColor {
        return UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    }
    
    static var SkyGray: UIColor {
        return UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }
    
    static var DarkSky: UIColor {
        return UIColor(red: 115.0 / 255.0, green: 195.0 / 255.0, blue: 211.0 / 255.0, alpha: 1.0)
    }
    
    static var backgroundFutureCell: UIColor {
        return UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    }
    
    static var BostonRedLight: UIColor {
        return UIColor(red: 221.0 / 255.0, green: 88.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
    }
    
    static var lightBurgundy: UIColor {
        return UIColor(red: 158.0 / 255.0, green: 54.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)
    }
    
    static var merchantColorOne: UIColor {
        return UIColor(red: 206.0 / 255.0, green: 154.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }
    
    static var merchantColorTwo: UIColor {
        return UIColor(red: 177.0 / 255.0, green: 220.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0)
    }
    
    static var merchantColorThree: UIColor {
        return UIColor(red: 153.0 / 255.0, green: 178.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    static var merchantColorFour: UIColor {
        return UIColor(red: 141.0 / 255.0, green: 217.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    }

    static var merchantColorFive: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 229.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
    }

    
    static var paleGrey: UIColor {
       UIColor(red: 245.0 / 255.0, green: 249.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
    }
}
