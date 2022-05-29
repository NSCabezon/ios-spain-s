//
//  TripDatePickerView.swift
//  PersonalArea
//
//  Created by César González Palomino on 31/03/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol TripDatePickerViewProtocol: AnyObject {
    func datePickerView(_ datePickerView: TripDatePickerView, didSelect date: Date)
}

struct TripDatePickerViewModel {
    let title: String
    let minDate: Date
    let currentDate: Date
    let maxDate: Date?
}

final class TripDatePickerView: XibView {
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    weak var delegate: TripDatePickerViewProtocol?
    
    private var field = UITextField()
    
    var pickerDate: Date {
        picker?.date ?? Date()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setInfo(_ info: TripDatePickerViewModel) {
        titleLabel.text = info.title
        picker?.minimumDate = info.minDate
        picker?.maximumDate = info.maxDate
        picker?.date = info.currentDate
        descriptionLabel.text = formateer.string(from: pickerDate).capitalized
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(minimunDate: Date) {
        picker?.minimumDate = minimunDate
        descriptionLabel.text = formateer.string(from: pickerDate).capitalized
    }
    
    func set(maximumDate: Date) {
        picker?.maximumDate = maximumDate
        descriptionLabel.text = formateer.string(from: pickerDate).capitalized
    }
    
    func set(currentDate: Date) {
        picker?.date = currentDate
        descriptionLabel.text = formateer.string(from: pickerDate).capitalized
    }
}

private extension TripDatePickerView {
    var picker: UIDatePicker? {
        field.inputView as? UIDatePicker
    }
    
    var formateer: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale.appLocale
        return dateFormatter
    }
    
    @objc func donePicker() {
        field.resignFirstResponder()
        guard let selectedDate = picker?.date else { return }
        descriptionLabel.text = formateer.string(from: selectedDate).capitalized
        delegate?.datePickerView(self, didSelect: selectedDate)
    }
    
    @objc func cancelPicker() {
        field.resignFirstResponder()
    }
    
    func setup() {
        configureView()
        configureLabels()
        configureField()
        configureImage()
    }
    
    func configureView() {
        view?.backgroundColor =  UIColor.black.withAlphaComponent(0.35)
        view?.layer.borderColor = UIColor.brownGray.cgColor
        view?.layer.borderWidth = 2.0
    }
    
    func configureImage() {
        icon.image = Assets.image(named: "icnWhiteCalendar")
    }
    
    func configureLabels() {
        [titleLabel, descriptionLabel].compactMap { $0?.text = "" }
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 12)
        titleLabel.textColor = .white
        descriptionLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        descriptionLabel.textColor = .white
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.5
    }
    
    func configureField() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.timeZone = TimeZone.current
        datePicker.locale = Locale.appLocale
        field.inputView = datePicker
        field.inputAccessoryView = getToolbar()
        addSubview(field)
        field.fullFit()
        field.tintColor = .clear
    }
    
    func getToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.santanderRed
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(
            title: localized("generic_button_accept"),
            style: UIBarButtonItem.Style.done,
            target: self,
            action: #selector(self.donePicker)
        )
        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
            target: nil,
            action: nil
        )
        let cancelButton = UIBarButtonItem(
            title: localized("generic_button_cancel"),
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(self.cancelPicker)
        )
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
}
