//
//  SecurityAreaViewProtocolModifier.swift
//  PersonalArea
//
//  Created by Jose Enrique Montero Prieto on 16/09/2021.
//

import Foundation

public protocol SecurityAreaViewProtocolModifier: AnyObject {
    var showIconTitleHeader: Bool { get }
    var tooltipItems: [(text: String, image: String)] { get }
}

extension SecurityAreaViewProtocolModifier {
    public var tooltipItems: [(text: String, image: String)] {
        [(text: "securityTooltip_text_secureDevice", image: "icnPhoneSecure"),
         (text: "securityTooltip_text_alert", image: "icnRing"),
         (text: "securityTooltip_text_fraud", image: "icnFraud"),
         (text: "securityTooltip_text_cardTheft", image: "icnStolenCard"),
         (text: "securityTooltip_text_permissions", image: "icnArrowPhone"),
         (text: "securityTooltip_text_travelMode", image: "icnParachute")]
    }
}
