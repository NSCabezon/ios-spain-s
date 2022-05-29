//
//  UIFont+Extension.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import Foundation

extension UIFont {
    
    static func loadFont(fromFile fileString: String) {
        let bundle = Bundle.module
        guard
            let pathForResourceString = bundle?.path(forResource: fileString, ofType: nil),
            let fontData = try? Data(contentsOf: URL(fileURLWithPath: pathForResourceString)),
            let dataProvider = CGDataProvider(data: fontData as CFData),
            let fontRef = CGFont(dataProvider)
        else {
            return
        }
        CTFontManagerRegisterGraphicsFont(fontRef, nil)
    }
}
