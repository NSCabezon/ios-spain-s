//
//  TripModeInfoTooltip.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 23/04/2020.
//

import UI
import CoreFoundationLib

final class TripModeInfoTooltip {
    
    func showTooltip(in viewController: UIViewController, from view: UIView?, isInitialToolTip: Bool? = nil) {
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: getStickyItems(),
                                                      scrolledItems: getScrolledItems())
        configuration.show(in: viewController, from: view, isInitialToolTip: isInitialToolTip)
    }
}

private extension TripModeInfoTooltip {
    func getStickyItems() -> [FullScreenToolTipViewItemData] {
        let titleView = getTooltipText(text: "security_button_travelMode", font: UIFont.santander(type: .light,
                                                                                                  size: 20),
                                       separator: 10)
        return [titleView]
    }
    
    func getScrolledItems() -> [FullScreenToolTipViewItemData] {
        let descriptionView = getTooltipText(text: "yourTripsTooltip_text_travelMode",
                                             font: .santander(size: 14),
                                             separator: 17)
        let cardsConfigView = getTooltipItem(text: "yourTripsTooltip_text_config", image: "icnBlockCard")
        let disableAlertsView = getTooltipItem(text: "yourTripsTooltip_text_alerts", image: "icnThief")
        let emergencyPhonesView = getTooltipItem(text: "yourTripsTooltip_text_emergency", image: "icnParachute")
        return [descriptionView, cardsConfigView, disableAlertsView, emergencyPhonesView]
    }
    
    func getTooltipText(text: String, font: UIFont, separator: CGFloat) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text),
                                                          left: 20,
                                                          right: 20,
                                                          font: font,
                                                          textColor: .lisboaGray)
        let view = LabelTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    func getTooltipItem(text: String, image: String) -> FullScreenToolTipViewItemData {
        let itemsFont = UIFont.santander(family: .text, type: .regular, size: 12)
        let separatorConfiguration = SeparatorViewConfiguration(color: UIColor.mediumSkyGray,
                                                                type: .dotted([1, 1]))
        let configuration = ItemTooltipViewConfiguration(image: Assets.image(named: image),
                                                         text: localized(text),
                                                         font: itemsFont,
                                                         separatorViewConfiguration: separatorConfiguration)
        let view = ItemTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 8)
        return item
    }
}
