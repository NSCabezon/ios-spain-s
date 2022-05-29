//
//  TimelineCellMerchantColors.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 24/09/2019.
//

import UIKit

class TimelineCellMerchantColors {
    
    static let shared = TimelineCellMerchantColors()
    private init() {}
    
    var merchantsSet: Set<String> = []
    let colors = [UIColor.merchantColorOne,
                  UIColor.merchantColorTwo,
                  UIColor.merchantColorThree,
                  UIColor.merchantColorFour,
                  UIColor.merchantColorFive]
    var colorIndex = 0
    var merchantsColors: [String: UIColor] = [:]
    
    func assignColorTo(merchant: String) -> UIColor {
        merchantsSet.insert(merchant)        
        let color = colors[colorIndex]
        merchantsColors[merchant] = color
        colorIndex == 4 ? (colorIndex = 0) : (colorIndex += 1)
        return color
    }
    
    func getColorFrom(merchant: String) -> UIColor {
        return merchantsColors[merchant] ?? colors[0]
    }
    
    func showIconWith(event: TimeLineEvent) -> Bool {
        if event.logo == nil,
            event.type == .bill || event.type == .cardSubscription,
            let name = event.merchant?.name,
            name != "" {
            return true
        } else {
            return false
        }
    }
        
}
