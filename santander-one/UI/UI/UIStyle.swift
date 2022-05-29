//
//  UIStyle.swift
//  UIStyle
//
//  Created by Jose Carlos Estela Anguita on 02/10/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import UIKit

public class UIStyle {
    
    public static func setup() {
        UIFont.loadFont(fromFile: "SantanderHeadline-Bold.ttf")
        UIFont.loadFont(fromFile: "SantanderHeadline-BoldIt.ttf")
        UIFont.loadFont(fromFile: "SantanderHeadline-It.ttf")
        UIFont.loadFont(fromFile: "SantanderHeadline-Regular.ttf")
        UIFont.loadFont(fromFile: "SantanderText-Bold.ttf")
        UIFont.loadFont(fromFile: "SantanderText-BoldItalic.ttf")
        UIFont.loadFont(fromFile: "SantanderText-Italic.ttf")
        UIFont.loadFont(fromFile: "SantanderText-Light.ttf")
        UIFont.loadFont(fromFile: "SantanderText-LightItalic.ttf")
        UIFont.loadFont(fromFile: "SantanderText-Regular.ttf")
        
        UIFont.loadFont(fromFile: "OpenSans-Bold.ttf")
        UIFont.loadFont(fromFile: "OpenSans-BoldItalic.ttf")
        UIFont.loadFont(fromFile: "OpenSans-ExtraBold.ttf")
        UIFont.loadFont(fromFile: "OpenSans-ExtraBoldItalic.ttf")
        UIFont.loadFont(fromFile: "OpenSans-Italic.ttf")
        UIFont.loadFont(fromFile: "OpenSans-Light.ttf")
        UIFont.loadFont(fromFile: "OpenSans-LightItalic.ttf")
        UIFont.loadFont(fromFile: "OpenSans-Medium.ttf")
        UIFont.loadFont(fromFile: "OpenSans-MediumItalic.ttf")
        UIFont.loadFont(fromFile: "OpenSans-Regular.ttf")
        UIFont.loadFont(fromFile: "OpenSans-SemiBold.ttf")
        UIFont.loadFont(fromFile: "OpenSans-SemiBoldItalic.ttf")
        
        UIFont.loadFont(fromFile: "Lato-Black.ttf")
        UIFont.loadFont(fromFile: "Lato-BlackItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Bold.ttf")
        UIFont.loadFont(fromFile: "Lato-BoldItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Hairline.ttf")
        UIFont.loadFont(fromFile: "Lato-HairlineItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Heavy.ttf")
        UIFont.loadFont(fromFile: "Lato-HeavyItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Italic.ttf")
        UIFont.loadFont(fromFile: "Lato-Light.ttf")
        UIFont.loadFont(fromFile: "Lato-LightItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Medium.ttf")
        UIFont.loadFont(fromFile: "Lato-MediumItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Regular.ttf")
        UIFont.loadFont(fromFile: "Lato-Semibold.ttf")
        UIFont.loadFont(fromFile: "Lato-SemiboldItalic.ttf")
        UIFont.loadFont(fromFile: "Lato-Thin.ttf")
        UIFont.loadFont(fromFile: "Lato-ThinItalic.ttf")

        UIFont.loadFont(fromFile: "Halter.ttf")
        
        UIFont.loadFont(fromFile: "SantanderMicroText-Regular.ttf")
        UIFont.loadFont(fromFile: "SantanderMicroText-Bold.ttf")
        
        Toast.configureToast()
    }
    
    public static func setupWidget() {        
        UIFont.loadFont(fromFile: "Lato-Bold.ttf")
        UIFont.loadFont(fromFile: "Lato-Light.ttf")
        UIFont.loadFont(fromFile: "Lato-Regular.ttf")
    }
}
