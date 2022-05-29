//
//  DigitalProfileTooltip.swift
//  PersonalArea
//
//  Created by alvola on 25/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

struct DigitalProfileTooltip {
    static func showTooltip(in viewController: UIViewController, from view: UIView?) {
        let titleView = getTooltipText(text: "digitalProfileTooltip_title_digitalProfile",
                                       font: UIFont.santander(size: 20),
                                       separator: 7,
                                       labelAccessibilityID: AccessibilityDigitalProfileTooltip.titleDigitalProfile)
        let descriptionView = getTooltipText(text: "digitalProfileTooltip_text_checkYourDigitalProfile",
                                             font: UIFont.santander(type: .light, size: 16),
                                             separator: 26,
                                             labelAccessibilityID: AccessibilityDigitalProfileTooltip.textCheckYourDigitalProfile)
        let typesView = getTooltipText(text: "digitalProfileTooltip_title_doYouKnow",
                                       font: UIFont.santander(type: .bold, size: 16),
                                       separator: 16,
                                       labelAccessibilityID: AccessibilityDigitalProfileTooltip.titleDoYouKnow)
        let cadet = getTooltipItem(text: "digitalProfileTooltip_text_cadet",
                                   percentages: "0-30%",
                                   name: "digitalProfile_label_cadet",
                                   image: AccessibilityDigitalProfileTooltip.icnMedalCadet,
                                   percentage: 0,
                                   percentagesLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelCadetPercentage,
                                   nameLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelCadet,
                                   descriptionLabelAccessibilityID: AccessibilityDigitalProfileTooltip.textCadet)
        let advanced = getTooltipItem(text: "digitalProfileTooltip_text_advanced",
                                      percentages: "30-60%",
                                      name: "digitalProfile_label_advanced",
                                      image: AccessibilityDigitalProfileTooltip.icnMedalAdvancedDigital,
                                      percentage: 50,
                                      percentagesLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelAdvancedPercentage,
                                      nameLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelAdvanced,
                                      descriptionLabelAccessibilityID: AccessibilityDigitalProfileTooltip.textAdvanced)
        let expert = getTooltipItem(text: "digitalProfileTooltip_text_expert",
                                    percentages: "60-90%",
                                    name: "digitalProfile_label_expert",
                                    image: AccessibilityDigitalProfileTooltip.icnMedalExpert,
                                    percentage: 75,
                                    percentagesLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelExpertPercentage,
                                    nameLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelExpert,
                                    descriptionLabelAccessibilityID: AccessibilityDigitalProfileTooltip.textExpert)
        let top = getTooltipItem(text: "digitalProfileTooltip_text_top",
                                 percentages: "90-100%",
                                 name: "digitalProfile_label_top",
                                 image: AccessibilityDigitalProfileTooltip.icnMedalTop,
                                 percentage: 100,
                                 percentagesLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelTopPercentage,
                                 nameLabelAccessibilityID: AccessibilityDigitalProfileTooltip.labelTop,
                                 descriptionLabelAccessibilityID: AccessibilityDigitalProfileTooltip.textTop)
        let stickyItems: [FullScreenToolTipViewItemData] = [titleView]
        let scrolledItems: [FullScreenToolTipViewItemData] = [descriptionView,
                                                              typesView,
                                                              cadet,
                                                              getSeparatorTooltip(),
                                                              advanced,
                                                              getSeparatorTooltip(),
                                                              expert,
                                                              getSeparatorTooltip(),
                                                              top]
        let configuration = FullScreenToolTipViewData(topMargin: 0,
                                                      stickyItems: stickyItems,
                                                      scrolledItems: scrolledItems,
                                                      closeIdentifier: AccessibilityDigitalProfileTooltip.btnInClose)
        configuration.show(in: viewController, from: view)
    }
    
    private static func getTooltipText(text: String, font: UIFont, separator: CGFloat, labelAccessibilityID: String) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text),
                                                   left: 20,
                                                   right: 20,
                                                   font: font,
                                                   textColor: .lisboaGray,
                                                   labelAccessibilityID: labelAccessibilityID)
        let view = LabelTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    private static func getSeparatorTooltip() -> FullScreenToolTipViewItemData {
        let view = DigitalProfileSeparatorTooltipView()
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 13)
        return item
    }
    
    private static func getTooltipItem(text: String, percentages: String, name: String, image: String, percentage: CGFloat, percentagesLabelAccessibilityID: String, nameLabelAccessibilityID: String, descriptionLabelAccessibilityID: String) -> FullScreenToolTipViewItemData {
        let configuration = DigitalProfileItemTooltipViewConfiguration(percentages: percentages,
                                                                       name: localized(name),
                                                                       description: localized(text),
                                                                       image: (Assets.image(named: image)),
                                                                       percentage: percentage,
                                                                       percentagesLabelAccessibilityID: percentagesLabelAccessibilityID,
                                                                       nameLabelAccessibilityID: nameLabelAccessibilityID,
                                                                       descriptionLabelAccessibilityID: descriptionLabelAccessibilityID)
        let view = DigitalProfileItemTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 13)
        return item
    }
}
