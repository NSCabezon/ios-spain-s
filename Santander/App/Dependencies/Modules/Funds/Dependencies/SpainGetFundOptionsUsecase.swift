//
//  SpainGetFundOptionsUsecase.swift
//  Santander
//
//  Created by Ernesto Fernandez Calles on 24/3/22.
//

import Funds
import CoreFoundationLib
import CoreDomain
import Foundation
import OpenCombine

struct SpainGetFundOptionsUsecase {}

extension SpainGetFundOptionsUsecase: GetFundOptionsUsecase {
    func fetchOptionsPublisher() -> AnyPublisher<[FundOptionRepresentable], Never> {
        return Just([operateOption, browserOption]).eraseToAnyPublisher()
    }
}

private extension SpainGetFundOptionsUsecase {
    var operateOption: FundOption {
        FundOption(title: "fundsOption_button_operate",
                   imageName: "icnOperate",
                   accessibilityIdentifier: AccessibilityIDLoansHome.optionScheduleContainer.rawValue,
                   type: .custom(identifier: "operate"),
                   titleIdentifier: "fundsOption_button_operate",
                   imageIdentifier: "icnOperate")
    }
    var browserOption: FundOption {
        FundOption(title: "fundsOption_button_fundBrowser",
                   imageName: "icnFundBrowser",
                   accessibilityIdentifier: AccessibilityIDLoansHome.optionCustomerServiceContainer.rawValue,
                   type: .custom(identifier: "browser"),
                   titleIdentifier: "fundsOption_button_fundBrowser",
                   imageIdentifier: "icnFundBrowser")
    }
}

private extension SpainGetFundOptionsUsecase {
    struct FundOption: FundOptionRepresentable {
        var title: String
        var imageName: String
        var accessibilityIdentifier: String
        var type: FundOptionType
        var titleIdentifier: String?
        var imageIdentifier: String?
    }
}
