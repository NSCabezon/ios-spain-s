//
//  AnalysisCarouselViewCellModel.swift
//  Menu
//
//  Created by David Gálvez Alonso on 30/03/2020.
//

import CoreFoundationLib

public struct AnalysisCarouselViewCellModel {
    
    public let amountStyle: UIColor
    public let circleValue: Decimal?
    public let amountText: Decimal?
    public let resumeText: LocalizedStylableText?
    public let percentageValue: CGFloat?
    public var userBudget: Decimal?
    public var modelType: AnalysisCarouselViewModelType

    public init(amountStyle: UIColor,
                circleValue: Decimal?,
                amountText: Decimal?,
                resumeText: LocalizedStylableText?,
                percentageValue: CGFloat? = 0.0,
                userBudget: Decimal? = nil,
                modelType: AnalysisCarouselViewModelType) {
        
        self.amountStyle = amountStyle
        self.circleValue = circleValue
        self.amountText = amountText
        self.resumeText = resumeText
        self.percentageValue = percentageValue
        self.userBudget = userBudget
        self.modelType = modelType
    }
}

public enum AnalysisCarouselViewModelType {
    case savings
    case budget
    case editBudget
}
