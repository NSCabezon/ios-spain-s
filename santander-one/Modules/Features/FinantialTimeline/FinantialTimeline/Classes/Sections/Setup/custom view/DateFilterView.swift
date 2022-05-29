//
//  DateFilterView.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 18/11/2019.
//

import UIKit

protocol DateFilterDelegate: AnyObject {
    func didUpdateValues(minimum: Float, maximum: Float, onlyFuture: Bool)
}

class DateFilterView: UIView {
    @IBOutlet var container: UIView!
    @IBOutlet weak var checkGroupView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: GlobileCards!
    @IBOutlet weak var monthsSlider: GlobileSlider!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthCountLabel: UILabel!
    
    weak var delegate: DateFilterDelegate?
    let checkonlyFuture = GlobileCheckBox()
    var checkGroup: GlobileCheckBoxGroup?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.module?.loadNibNamed(String(describing: DateFilterView.self), owner: self, options: [:])
        addSubviewWithAutoLayout(container)
        prepareUI()
    }
    
    private func prepareUI() {
        setTitle()
        prepareMonthsLabels()
        prepareFutureCheck()
        prepareSlider()
    }
    
    private func setTitle() {
        prepare(titleLabel, with: UIFont.santanderText(type: .bold, with: 17),
                color: .greyishBrown,
                and: SetupString().displayDateTitle)
    }
    
    private func prepareMonthsLabels() {
        prepare(monthLabel, with: UIFont.santanderText(type: .regular, with: 12),
                color: .greyishBrown,
                and: SetupString().months)
        prepare(monthCountLabel, with: UIFont.santanderText(type: .regular, with: 17),
                color: .greyishBrown,
                and: "")
    }
    
    private func prepare(_ label: UILabel, with font: UIFont, color: UIColor, and text: String) {
        label.font = font
        label.textColor = color
        label.text = text
    }
    
    private func prepareFutureCheck() {
        checkonlyFuture.isSelected = false
        checkonlyFuture.text = SetupString().showOnlyFuture
        checkonlyFuture.color = .turquoise
        checkGroup = GlobileCheckBoxGroup(checkboxes: [checkonlyFuture])
        checkGroup?.delegate = self
        checkGroupView.addSubviewWithAutoLayout(checkGroup!)
    }
    
    private func prepareSlider() {
        setMin(to: -3)
        setMax(to: 3)
        monthsSlider.isContinuous = false
        monthsSlider.step = 1
        monthsSlider.isRangeable = true
        monthsSlider.color = .turquoise
        monthsSlider.delegate = self
    }
    
    private func setMonthsDifference() {
        let difference = Double(abs(monthsSlider.selectedMinimumValue - monthsSlider.selectedMaximumValue)) + 1
        let format = difference == 1 ?  SetupString().singularMonths :  SetupString().pluralmonths
        monthCountLabel.text = String(format: format, difference.asString(with: 0))
    }
    
    private func setMin(to value: Float) {
        monthsSlider.minimumValue = value
        monthsSlider.selectedMinimumValue = value
        monthsSlider.minimumText = "\(Double(value).asString(with: 0))"
        onUpdated(minimumValue: monthsSlider.selectedMinimumValue, maximumValue: monthsSlider.selectedMaximumValue)
    }
    
    private func setMax(to value: Float) {
        monthsSlider.maximumValue = value
        monthsSlider.selectedMaximumValue = value
        monthsSlider.maximumText = "\(Double(value).asString(with: 0))"
        onUpdated(minimumValue: monthsSlider.selectedMinimumValue, maximumValue: monthsSlider.selectedMaximumValue)
    }
    
    private func moveMin(to value: Float) {
        monthsSlider.selectedMinimumValue = value
        onUpdated(minimumValue: monthsSlider.selectedMinimumValue, maximumValue: monthsSlider.selectedMaximumValue)
    }
    
    private func movMax(to value: Float) {
        monthsSlider.selectedMaximumValue = value
        onUpdated(minimumValue: monthsSlider.selectedMinimumValue, maximumValue: monthsSlider.selectedMaximumValue)
    }
    
    func set(_ delegate: DateFilterDelegate) {
        self.delegate = delegate
        onUpdated(minimumValue: monthsSlider.selectedMinimumValue, maximumValue: monthsSlider.selectedMaximumValue)
        checkLocalStorage()
    }
    
    private func checkLocalStorage() {
        guard let blackList = SecureStorageHelper.getBlackList() else { return }
        
        if let future = blackList.onlyFuture {
            checkonlyFuture.isSelected = future
            if future {
                setMin(to: 0)
            } else {
                setMin(to: -3)
            }
        }
        
        if let minMonth = blackList.minNumberOfMonths {
            moveMin(to: Float(minMonth))
        }
        
        if let maxMonth = blackList.maxNumberOfMonths {
            movMax(to: Float(maxMonth))
        }
    }
}

extension DateFilterView: GlobileSliderDelegate {
    func globileSlider(_ slider: GlobileSlider, didChange minimumValue: Float, maximumValue: Float) {
        onUpdated(minimumValue: minimumValue, maximumValue: maximumValue)
    }
    
    func onUpdated(minimumValue: Float, maximumValue: Float) {
        delegate?.didUpdateValues(minimum: minimumValue, maximum: maximumValue, onlyFuture: checkonlyFuture.isSelected)
        setMonthsDifference()
    }
}

extension DateFilterView: GlobileCheckboxGroupDelegate {
    func didSelect(checkbox: GlobileCheckBox) {
        setMin(to: 0)
    }
    
    func didDeselect(checkbox: GlobileCheckBox) {
        setMin(to: -3)
    }
}
