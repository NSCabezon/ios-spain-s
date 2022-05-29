//
//  LegacyColors.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/30/20.
//

import Foundation
extension UIColor {
    public struct Legacy {
        // Colors that require alpha different than 1.0 should not be added here, use withAlphaComponent(Double) instead.
         
         // Corporate Colors
         
         /// #FFFFFF
         /// rgb(255, 255, 255)
         public static let uiWhite = UIColor(white: 255.0 / 255.0, alpha: 1.0)
         
         /// #EC0000
         /// rgb(236, 0, 0)
         public static let sanRed = UIColor(red: 236.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
         
         /// #1BB3BC
         /// rgb(27, 179, 188)
         public static let topaz = UIColor(red: 27.0 / 255.0, green: 179.0 / 255.0, blue: 188.0 / 255.0, alpha: 1.0)

         /// #000000
         /// rgb(0, 0, 0)
         public static let uiBlack = UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)

         // Greys
         
         /// #F5F7FA, also known as paleGrey
         /// rgb(245, 247, 250)
         public static let uiBackground = UIColor(red: 245.0 / 255.0, green: 247.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)

         /// #D8D8D8
         /// rgb(216, 216, 216)
         public static let sanGrey = UIColor(white: 216.0 / 255.0, alpha: 1.0)
         
         /// #9B9B9B
         /// rgb(155, 155, 155)
         public static let sanGreyMedium = UIColor(white: 155.0 / 255.0, alpha: 1.0)
         
         /// #4A4A4A
         /// rgb(74, 74, 74)
         public static let sanGreyDark = UIColor(white: 74.0 / 255.0, alpha: 1.0)

         /// #ECEFF3
         /// rgb(236, 239, 243)
         public static let sanGreyLight = UIColor(red: 236.0 / 255.0, green: 239.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)

         /// #EFF6F9
         /// rgb(239, 246, 249)
         public static let sanGreyNew = UIColor(red: 239.0 / 255.0, green: 246.0 / 255.0, blue: 249.0 / 255.0, alpha: 1.0)
         
         /// #F7FBFC
         /// rgb(247, 251, 252)
         public static let paleGray = UIColor(red: 247.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)

         /// #6F7779
         /// rgb(111, 119, 121)
         public static let deepSanGrey = UIColor(red: 111.0 / 255.0, green: 119.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)
         
         /// #ECF3F7
         /// rgb(236, 243, 247)
         public static let prominentGray: UIColor = UIColor(red: 236.0/255.0, green: 243.0/255.0, blue: 247.0/255.0, alpha: 1.0)

         /// #CEDEE7
         /// rgb(206, 222, 231)
         public static let mediumSky: UIColor = UIColor(red: 206.0/255.0, green: 222.0/255.0, blue: 231.0/255.0, alpha: 1.0)

         /// #9BC3D3
         /// rgb(155, 195, 211)
         public static let botonRedLight: UIColor = UIColor(red: 221.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1.0)

         /// #1BB3BC
         /// rgb(27, 179, 188)
         public static let turquoise: UIColor = UIColor(red: 27.0/255.0, green: 179.0/255.0, blue: 188.0/255.0, alpha: 1.0)
         
         /// #CCCCCC
         /// rgb(204, 204, 204)
         public static let lisboaLightGray: UIColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)

         /// #CCCCCC
         /// rgb(105, 105, 105)
         public static let shadowGray: UIColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
         
         // MARK: - Oros App
         
         /// #9AB000
         /// rgb(154, 176, 0)
         public static let green = UIColor(red: 154.0 / 255.0, green: 176.0 / 255.0, blue: 0.0, alpha: 1.0)

         /// #F54B4B
         /// rgb(245, 75, 75)
         public static let coral = UIColor(red: 245.0 / 255.0, green: 75.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)

         /// #F09500
         /// rgb(240, 149, 0)
         public static let orange = UIColor(red: 240.0 / 255.0, green: 149.0 / 255.0, blue: 0.0, alpha: 1.0)

         /// #9E3667
         /// rgb(158, 54, 103)
         public static let purple = UIColor(red: 158.0 / 255.0, green: 54.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)

         /// #FFF688
         /// rgb(255, 246, 136)
         public static let yellowBackground = UIColor(red: 255.0 / 255.0, green: 246.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
         
         // MARK: - Gradients
         
         /// #CA0000
         /// rgb(202, 0, 0)
         public static let toolbar1 = UIColor(red: 202.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)

         /// #D40303
         /// rgb(212, 3, 3)
         public static let toolbarPB1 = UIColor(red: 212.0 / 255.0, green: 3.0 / 255.0, blue: 3.0 / 255.0, alpha: 1.0)
         
         /// #B42C29
         /// rgb(180, 44, 41)
         public static let toolbarPB2 = UIColor(red: 180.0 / 255.0, green: 44.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)

         /// #A9351D
         /// rgb(169, 53, 29)
         public static let toolbarPB3 = UIColor(red: 169.0 / 255.0, green: 53.0 / 255.0, blue: 29.0 / 255.0, alpha: 1.0)
         
         /// #FEFEFE
         /// rgb(254, 254, 254)
         public static let keyboardWhite: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 1.0)
         
         /// #04040F
         /// rgb(4, 4, 15)
         public static let keyboardPress: UIColor = UIColor(red: 4.0/255.0, green: 4.0/255.0, blue: 15.0/255.0, alpha: 1.0)
         
         /// rgb(222 237 242)
         public static let sky: UIColor = UIColor(red: 222.0/255.0, green: 237.0/255.0, blue: 242.0/255.0, alpha: 1.0)
         
         /// rgb(155 195 211)
         public static let lightGreyBlue: UIColor = UIColor(red: 155.0/255.0, green: 195.0/255.0, blue: 211.0/255.0, alpha: 1.0)
         
         // MARK: - Lisboa colors
         
         public static let lisboaGray = UIColor(white: 216.0 / 255.0, alpha: 1.0)
         
         /// rgb(68, 68, 68)
         public static let lisboaGrayNew = UIColor(white: 68.0 / 255.0, alpha: 1.0)
         
         /// rgb (236 0 0)
         public static let santanderRed: UIColor = UIColor(red: 236.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
         
         /// rgb(194, 209, 217)
         public static let dotGray: UIColor = UIColor(red: 194.0/255.0, green: 209.0/255.0, blue: 217.0/255.0, alpha: 1.0)
         /// rgb (236 0 0)
         public static let paleSanGrey: UIColor = UIColor(red: 235.0/255.0, green: 242.0/255.0, blue: 245.0/255.0, alpha: 1.0)
         
         /// rgb (204 204 204)
         public static let lightSanGrey: UIColor = UIColor(white: 204.0/255.0, alpha: 1.0)
         
         /// rgb (204 0 0)
         public static let bostonRed: UIColor = UIColor(red: 204.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
         
         public static let sky30: UIColor = UIColor(red: 244.0 / 255.0, green: 246.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }
}
