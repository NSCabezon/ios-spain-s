//
//  NavigationToolTip.swift
//  UI
//
//  Created by Juan Carlos López Robles on 3/3/20.
//

import Foundation
import CoreFoundationLib

public final class NavigationToolTip {
    var titleView: LabelTooltipView?
    var descriptionView: LabelTooltipView?
    var closeIdentifier: String?
    var titleIdentifier: String?
    var textIdentifier: String?
    var containerIdentifier: String?
    
    public init() { }
    
    public func add(title: LocalizedStylableText) {
        let titleConfiguration = LabelTooltipViewConfiguration(
            text: title, left: 18, right: 18,
            font: .santander(family: .text, type: .bold, size: 20), textColor: .lisboaGray)
        self.titleView = LabelTooltipView(configuration: titleConfiguration)
    }

    public func add(description: LocalizedStylableText) {
        let textConfiguration = LabelTooltipViewConfiguration(
            text: description, left: 18, right: 18,
            font: .santander(family: .text, type: .light, size: 16), textColor: .lisboaGray)
        self.descriptionView = LabelTooltipView(configuration: textConfiguration)
    }
    
    public func add(closeIndentifier: String) {
        self.closeIdentifier = closeIndentifier
    }
    
    public func add(titleIdentifier: String) {
        self.titleIdentifier = titleIdentifier
    }
    
    public func add(textIdentifier: String) {
        self.textIdentifier = textIdentifier
    }
    
    public func add(containerIdentifier: String) {
        self.containerIdentifier = containerIdentifier
    }
    
    public func show(in viewController: UIViewController, from sender: UIView?, isInitialToolTip: Bool? = nil) {
        guard let titleView = self.titleView else { return }
        guard let descriptionView = self.descriptionView else { return }
        titleView.setLabelIdentifier(self.titleIdentifier)
        descriptionView.setLabelIdentifier(self.textIdentifier)
        let stickyItems: [FullScreenToolTipViewItemData] = [FullScreenToolTipViewItemData(view: titleView, bottomMargin: 7)]
        let scrolledItems: [FullScreenToolTipViewItemData] = [FullScreenToolTipViewItemData(view: descriptionView, bottomMargin: 30)]
        let configuration = FullScreenToolTipViewData(topMargin: 0,
                                                      stickyItems: stickyItems,
                                                      scrolledItems: scrolledItems,
                                                      closeIdentifier: self.closeIdentifier,
                                                      containerIdentifier: self.containerIdentifier)
        configuration.show(in: viewController, from: sender, isInitialToolTip: isInitialToolTip ?? false)
    }
}
