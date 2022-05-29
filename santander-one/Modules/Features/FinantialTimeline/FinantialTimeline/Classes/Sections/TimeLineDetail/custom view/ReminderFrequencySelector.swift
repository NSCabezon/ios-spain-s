//
//  ReminderFrequencySelector.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 09/10/2019.
//

import UIKit

class ReminderFrequencySelector: UIView {
    @IBOutlet var container: UIView!

    var remindmeDropdown = GlobileDropdown<AlertType>()
    weak var delegate: ReminderFrequencySelectorDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
      
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
      
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: ReminderFrequencySelector.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
    
    private func prepareUI() {
         ()
        configureAlertDropDown()
        container.addSubviewWithAutoLayout(remindmeDropdown, topAnchorConstant: .equal(to: 0), leftAnchorConstant: .equal(to: 0), rightAnchorConstant: .equal(to: 0))
    }
    
    private func configureAlertDropDown() {
        let sameDayItem = GlobileDropdownData(label: TimeLineDetailString().sameDay, value: AlertType.sameDay)
        let dayBeforeItem = GlobileDropdownData(label: TimeLineDetailString().dayBefore, value: AlertType.dayBefore)
        let weekBeforeItem = GlobileDropdownData(label: TimeLineDetailString().weekBefore, value: AlertType.weekBefore)
        let items = [sameDayItem, dayBeforeItem, weekBeforeItem]
        
        remindmeDropdown.dropDownDelegate = self
        remindmeDropdown.color = .red
        remindmeDropdown.items = items
        remindmeDropdown.color = .turquoise
        remindmeDropdown.theme = .white
        remindmeDropdown.hintMessage = TimeLineDetailString().remindMe
        remindmeDropdown.floatingMessage = TimeLineDetailString().remindMe
    }
    
    func set(alertType type: String?) {
        if let alert = type {
            switch alert {
            case "0":
                remindmeDropdown.itemSelected = 0
            case "1":
                remindmeDropdown.itemSelected = 1
            case "2":
                remindmeDropdown.itemSelected = 2
            default:
                break
            }
        }
    }
    
}

extension ReminderFrequencySelector: GlobileDropDownDelegate {
    func dropDownSelected<T>(_ item: GlobileDropdownData<T>, _ sender: GlobileDropdown<T>) {
        delegate?.reminderDropDownSelected(item, sender)
    }
    
    func dropdownExpanded<T>(_ sender: GlobileDropdown<T>) {
        delegate?.reminderDropdownExpanded(sender)
    }
    
    func dropdownCompressed<T>(_ sender: GlobileDropdown<T>) {
        delegate?.reminderDropdownCompressed(sender)
    }
}

protocol ReminderFrequencySelectorDelegate: AnyObject {
    func reminderDropDownSelected<T>(_ item: GlobileDropdownData<T>, _ sender: GlobileDropdown<T>)
    func reminderDropdownExpanded<T>(_ sender: GlobileDropdown<T>)
    func reminderDropdownCompressed<T>(_ sender: GlobileDropdown<T>)
}
