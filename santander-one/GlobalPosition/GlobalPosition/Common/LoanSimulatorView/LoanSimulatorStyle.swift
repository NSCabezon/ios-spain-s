//
//  LoanSimulatorStyle.swift
//  GlobalPosition
//

import UI

struct LoanSimulatorStyle {
    
    private static func regularWith(size: CGFloat) -> UIFont {
        UIFont.santander(family: .text, type: .regular, size: size)
    }
    
    private static func boldWith(size: CGFloat) -> UIFont {
        UIFont.santander(family: .text, type: .bold, size: size)
    }
    
    let headerBackgroundColor = UIColor.blueAnthracita
    
    let amountTitleFont = regularWith(size: 16.0)
    let amountTitleColor = UIColor.grafite
    
    let amountValueFont = boldWith(size: 22.0)
    let amountValueColor = UIColor.lisboaGray
    
    let minimumValueFont = regularWith(size: 14.0)
    let minimumValueColor = UIColor.mediumSanGray
    
    let maximumValueFont = regularWith(size: 14.0)
    let maximumValueColor = UIColor.mediumSanGray
    let maximunValueAligment = NSTextAlignment.right
    
    let circularSliderLabelFont = regularWith(size: 11.0)
    let circularSliderLabelColor = UIColor.mediumSanGray
    
    let openingCommissionFont = regularWith(size: 12.0)
    let openingComissionColor = UIColor.mediumSanGray

    let monthsFont = regularWith(size: 11.0)
    let monthsColor = UIColor.mediumSanGray
    
    let monthsValuefont = boldWith(size: 16.0)
    let monthsValueColor = UIColor.lisboaGray
    
    let TINFont = regularWith(size: 12.0)
    let TINColor = UIColor.mediumSanGray
    
    let TAEFont = regularWith(size: 12.0)
    let TAEColor = UIColor.mediumSanGray
    
    let monthlyFeeFont = regularWith(size: 13.0)
    let monthlyFeeColor = UIColor.mediumSanGray
    
    let monthlyFeeValueFont = boldWith(size: 24.0)
    let monthlyFeeValueColor = UIColor.darkTorquoise
    
    let moreInfoFont = regularWith(size: 16.0)
    let moreInfoColor = UIColor.santanderRed
    
    let sliderMinimumTrackTintColor = UIColor.darkTorquoise
    let sliderMaximumTracktTintColor = UIColor.lightSanGray
    
    let textFieldBackgroundColor = UIColor.skyGray
    
    let circularSliderFilledColor = UIColor.darkTorquoise
    let circularSliderUnFilledColor = UIColor.lightSanGray
    let circularSliderMarkerColor = UIColor.ultraDarkTurquoise
    let circularSliderMarkerSize = CGSize(width: 12.0, height: 12.0)
    
}
