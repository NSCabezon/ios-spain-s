//
//  Fonts.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import UIKit
import CoreFoundationLib

extension UIFont {

    public static func santander(family: FontFamily = FontFamily.text, type: FontType = .regular, size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: family, type: type, size: size)
    }

    public static func halterRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Halter", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    public func font(with emphasis: FontEmphasis, factor: CGFloat = 1.0) -> UIFont? {
        guard let fontName = fontName.split("-").first else {
            return nil
        }
        var fullFontName = fontName
        if !emphasis.rawValue.isEmpty {
            fullFontName += "-" + emphasis.rawValue
        }

        return UIFont(name: fullFontName, size: pointSize * factor)
    }
}

extension UIFont {

    /**
     Load the font into the project, without the necessity of saving the fonts in .plist

     - Parameters: fileString: The name of the font Ex: "Lato-Light.ttf"

     - Returns: Void
     */
    static func loadFont(fromFile fileString: String) {
        guard
            let bundle: Bundle = Bundle.module,
            let pathForResourceString: String = bundle.path(forResource: fileString, ofType: nil),
            let fontData: Data = try? Data(contentsOf: URL(fileURLWithPath: pathForResourceString)),
            let dataProvider: CGDataProvider = CGDataProvider(data: fontData as CFData),
            let fontRef: CGFont = CGFont(dataProvider)
        else {
            assertionFailure("Couldn't load \(fileString)")
            return
        }
        CTFontManagerRegisterGraphicsFont(fontRef, nil)
    }
}
