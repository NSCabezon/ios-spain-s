//
//  HelpCenterTooltip.swift
//  PersonalArea
//
//  Created by Iván Estévez on 21/04/2020.
//

import UI
import CoreFoundationLib

final class HelpCenterTooltip {
    func showTooltip(in viewController: UIViewController, from view: UIView?) {
        let titleView = getTooltipText(text: "helpCenterTooltip_title_helpCenter", font: .santander(family: .text, type: .bold, size: 20), separator: 7, labelIdentifier: "helpCenter_tooltip_title")
        let descriptionView = getTooltipText(text: "helpCenterTooltip_text_helpCenter", font: .santander(family: .text, type: .light, size: 16), separator: 19, labelIdentifier: "helpCenter_tooltip_text")
        let moreView = getTooltipText(text: "tooltip_title_section", font: .santander(family: .text, type: .bold, size: 18), separator: 8, labelIdentifier: "helpCenter_tooltip_titleSection")
        let assistant = getTooltipItem(text: "helpCenterTooltip_text_assistant", image: "icnAssistant", textIdentifier: "helpCenter_tooltip_assistantText", imageIdentifier: "icnAssistant")
        let contact = getTooltipItem(text: "helpCenterTooltip_text_contact", image: "icnHelpCall", textIdentifier: "helpCenter_tooltip_contactText", imageIdentifier: "icnHelpCall")
        let operatives = getTooltipItem(text: "helpCenterTooltip_text_emergencyCase", image: "icnOperate", textIdentifier: "helpCenter_tooltip_emergencyCaseText", imageIdentifier: "icnOperate")
        let stickyItems: [FullScreenToolTipViewItemData] = [titleView]
        let scrolledItems: [FullScreenToolTipViewItemData] = [descriptionView, moreView, assistant, contact, operatives]
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: stickyItems, scrolledItems: scrolledItems, closeIdentifier: "helpCenter_tooltip_closeButton", containerIdentifier: "helpCenter_tooltip_container")
        configuration.show(in: viewController, from: view)
    }
}

private extension HelpCenterTooltip {
    func getTooltipText(text: String, font: UIFont, separator: CGFloat, labelIdentifier: String? = nil) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text),
                                                   left: 20,
                                                   right: 20,
                                                   font: font,
                                                   textColor: .lisboaGray)
        let view = LabelTooltipView(configuration: configuration, labelIdentifier: labelIdentifier)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    func getTooltipItem(text: String, image: String, textIdentifier: String? = nil, imageIdentifier: String? = nil) -> FullScreenToolTipViewItemData {
        let configuration = HelpCenterItemTooltipViewConfiguration(image: Assets.image(named: image), text: localized(text))
        let view = HelpCenterItemTooltipView(configuration: configuration, labelIdentifier: textIdentifier, imageIdentifier: imageIdentifier)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 8)
        return item
    }
}
