//
//  LisboaSegmentedWithImageAndTitle.swift
//  UI
//
//  Created by Ignacio González Miró on 14/10/2020.
//

import UIKit
import CoreFoundationLib

public protocol DidTapInCardsSegmentedDelegate: AnyObject {
    func didTapInCardSegmented(_ index: Int)
}

public enum SegmentedCardType: Int {
    case owner = 0
    case associated = 1
}

public final class LisboaSegmentedWithImageAndTitle: UIDesignableView {
    @IBOutlet private weak var segmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var leftItem: SegmentedItemWithImageAndText!
    @IBOutlet private weak var rightItem: SegmentedItemWithImageAndText!
    
    weak public var delegate: DidTapInCardsSegmentedDelegate?

    override public func getBundleName() -> String {
        return "UI"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    public func setInfo(_ leftCardName: String, rightCardName: String, ownerCardUrl: String, associatedCardUrl: String) {
        let lisboaSegmentedTitles = ["", ""]
        let lisboaAccessibilityIds = [AccessibilitySegmentWithImageAndTitle.segmentedPill.rawValue, AccessibilitySegmentWithImageAndTitle.segmentedPill.rawValue]
        self.segmentedControl.setup(with: lisboaSegmentedTitles, accessibilityIdentifiers: lisboaAccessibilityIds, withStyle: .lightGraySegmentedControlStyle)
        self.leftItem.setupSegmentedItem(leftCardName, urlString: ownerCardUrl)
        self.rightItem.setupSegmentedItem(rightCardName, urlString: associatedCardUrl)
    }
    
    @IBAction public func didTapOnSegmented(_ sender: LisboaSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case SegmentedCardType.owner.rawValue:
            self.updateLabelFont(true)
        case SegmentedCardType.associated.rawValue:
            self.updateLabelFont(false)
        default:
            break
        }
        delegate?.didTapInCardSegmented(sender.selectedSegmentIndex)
    }
    
    public func setSecondarySegmentedSelected() {
        self.segmentedControl.selectedSegmentIndex = SegmentedCardType.associated.rawValue
        self.updateLabelFont(false)
    }
}

private extension LisboaSegmentedWithImageAndTitle {
    func setupView() {
        self.setAccessibilityIds()
        self.addTapGestureToViews()
        self.heightAnchor.constraint(equalToConstant: 84.0).isActive = true
        self.segmentedControl.selectedSegmentIndex = SegmentedCardType.owner.rawValue
        self.updateLabelFont(true)
    }
    
    func setAccessibilityIds() {
        self.segmentedControl.accessibilityIdentifier = AccessibilitySegmentWithImageAndTitle.segmentedControl.rawValue
        self.leftItem.accessibilityIdentifier = AccessibilitySegmentWithImageAndTitle.segmentedPill.rawValue
        self.rightItem.accessibilityIdentifier = AccessibilitySegmentWithImageAndTitle.segmentedPill.rawValue
    }
    
    func updateLabelFont(_ isOwnerCard: Bool) {
        self.leftItem.setLabel(isOwnerCard)
        self.rightItem.setLabel(!isOwnerCard)
    }
    
    func addTapGestureToViews() {
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInLeftItem))
        self.leftItem.addGestureRecognizer(leftTapGesture)
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInRightItem))
        self.rightItem.addGestureRecognizer(rightTapGesture)
    }
    
    @objc func didTapInLeftItem() {
        self.segmentedControl.selectedSegmentIndex = SegmentedCardType.owner.rawValue
        self.didTapOnSegmented(segmentedControl)
    }
    
    @objc func didTapInRightItem() {
        self.segmentedControl.selectedSegmentIndex = SegmentedCardType.associated.rawValue
        self.didTapOnSegmented(segmentedControl)
    }
}
