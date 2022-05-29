//
//  NewCustomEventViewController.swift
//  FinantialTimeline-FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 04/09/2019.
//


import UIKit

class NewCustomEventViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var eventTitleTextfield: GlobileTextfield!
    @IBOutlet weak var eventDescriptionTextfield: GlobileTextfield!
    @IBOutlet weak var sinceTextfield: GlobileTextfield!
    @IBOutlet weak var untilTextfield: GlobileTextfield!
    @IBOutlet weak var confirmButton: GlobileEndingButton!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var confirmViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmView: UIView!
    
    
    // MARK: - Dependencies
    var presenter: NewCustomEventPresenterProtocol?
    
    // MARK: - Properties
    let frequencyDropdown = GlobileDropdown<Frequency>()
    let zero = GlobileDropdownData<Frequency>(label: IBLocalizedString("timeline.newcustomeventSection.event.frequency.none"), value: .withoutFrequency)
    let weekly = GlobileDropdownData<Frequency>(label: IBLocalizedString("timeline.newcustomeventSection.event.frequency.weekly"), value: .weekly)
    let twoWeeks = GlobileDropdownData<Frequency>(label: IBLocalizedString("timeline.newcustomeventSection.event.frequency.twoweeks"), value: .everyTwoWeeks)
    let monthly = GlobileDropdownData<Frequency>(label: IBLocalizedString("timeline.newcustomeventSection.event.frequency.monthly"), value: .monthly)
    let annually = GlobileDropdownData<Frequency>(label: IBLocalizedString("timeline.newcustomeventSection.event.frequency.annually"), value: .annually)
    
    let datePickerView = UIDatePicker()
    var newCustomEvent = NewCustomEventViewControllerOutput()
    let frequencyErrorLabel = UILabel()

    
    // MARK: -
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        view.addGestureRecognizer(dismissKeyboardGesture)
        configView()
        presenter?.viewDidLoad()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Config View
    private func configView() {
        frequencyDropdown.dropDownDelegate = self
        configureBack()
        configEventTitle()
        configEventDescription()
        configFrequencyDropdown()
        configSince()
        configUntil()
        configConfirm()
        configConfirmLabel()
    }
    
    private func configureBack() {
        let barButton = UIBarButtonItem(image: UIImage(fromModuleWithName: "backButton"), style: .plain, target: self, action: #selector(onBackPressed))
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func onBackPressed() {
        presenter?.onBackPressed()
    }
    
    private func configEventTitle() {
        eventTitleTextfield.delegate = self
        eventTitleTextfield.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        eventTitleTextfield.setPlaceholder(IBLocalizedString("timeline.newcustomeventSection.event.conceptTitle"))
        eventTitleTextfield.setBottomLabel(IBLocalizedString("timeline.newcustomeventSection.event.conceptTitle.required"))
    }
    
    private func configEventDescription() {
        eventDescriptionTextfield.delegate = self
        eventDescriptionTextfield.addTarget(self, action:  #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        eventDescriptionTextfield.setPlaceholder(IBLocalizedString("timeline.newcustomeventSection.event.description"))
        eventDescriptionTextfield.setBottomLabel(IBLocalizedString("timeline.newcustomeventSection.event.description.optional"))
    }
    
    private func configFrequencyDropdown() {
        frequencyDropdown.items = [zero, weekly, twoWeeks, monthly, annually]
        frequencyDropdown.hintMessage = IBLocalizedString("timeline.newcustomeventSection.event.frequency.hint")
        frequencyDropdown.backgroundColor = .white
        frequencyDropdown.color = GlobileDropDownTintColor.turquoise
                
        view.insertSubview(frequencyDropdown, aboveSubview: scrollContentView)
        frequencyDropdown.translatesAutoresizingMaskIntoConstraints = false
        frequencyDropdown.topAnchor.constraint(equalTo: eventDescriptionTextfield.bottomAnchor, constant: 46).isActive = true
        frequencyDropdown.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16).isActive = true
        frequencyDropdown.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16).isActive = true
        
        view.addSubview(frequencyErrorLabel)
        frequencyErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyErrorLabel.leadingAnchor.constraint(equalTo: frequencyDropdown.leadingAnchor, constant: 4).isActive = true
        frequencyErrorLabel.trailingAnchor.constraint(equalTo: frequencyDropdown.trailingAnchor, constant: -4).isActive = true
        frequencyErrorLabel.topAnchor.constraint(equalTo: frequencyDropdown.bottomAnchor, constant: -15).isActive = true
        frequencyErrorLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        frequencyErrorLabel.text = IBLocalizedString("timeline.newcustomeventSection.event.frequency.error")
        frequencyErrorLabel.font = .santanderText(type: .regular, with: 14)
        frequencyErrorLabel.textColor = .bostonRed
        frequencyErrorLabel.textAlignment = .left
        frequencyErrorLabel.numberOfLines = 0
        frequencyErrorLabel.isHidden = true
    }
    
    private func configSince() {
        sinceTextfield.delegate = self
        sinceTextfield.translatesAutoresizingMaskIntoConstraints = false
        sinceTextfield.topAnchor.constraint(equalTo: frequencyDropdown.bottomAnchor, constant: 46).isActive = true
        sinceTextfield.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16).isActive = true
        sinceTextfield.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: 16).isActive = true
        sinceTextfield.setPlaceholder(IBLocalizedString("timeline.newcustomeventSection.event.since"))
        sinceTextfield.rightIcon = UIImage(fromModuleWithName: "icCalendar")?.withRenderingMode(.alwaysTemplate)
        sinceTextfield.tintColor = .sanRed
    }
    
    private func configUntil() {
        untilTextfield.delegate = self
        untilTextfield.isEnabled = false
        untilTextfield.setPlaceholder(IBLocalizedString("timeline.newcustomeventSection.event.until"))
        untilTextfield.rightIcon = UIImage(fromModuleWithName: "icCalendar")?.withRenderingMode(.alwaysTemplate)
        untilTextfield.tintColor = .sanRed
    }
    
    private func configConfirm() {
        view.bringSubviewToFront(confirmView)
        confirmButton.isEnabled = false
        confirmButton.setTitle(IBLocalizedString("timeline.newcustomeventSection.event.confirm"), for: .normal)
        confirmButton.backgroundColor = UIColor(red: 239/255, green: 246/255, blue: 249/255, alpha: 1)
        confirmButton.titleLabel?.font = UIFont.santanderText(type: .regular, with: 16)
    }
    
    private func configConfirmLabel() {
        confirmLabel.text = IBLocalizedString("timeline.newcustomeventSection.event.confirm.label")
        confirmLabel.font = .santanderText(type: .boldItalic, with: 14)
        confirmLabel.textColor = UIColor(white: 118/255, alpha: 1)
    }
    
    // MARK: - Actions
    @IBAction func sincePickDate(_ sender: UITextField) {
        showDatePicker(sender: sender)
    }
    
    @IBAction func untilPickDate(_ sender: UITextField) {
        showDatePicker(sender: sender)
    }
    
    @IBAction func createCustomEvent(_ sender: Any) {
        presenter?.createCustomEventTapped(newCustomEvent)
    }
    
    @objc func datePickerDone(_ sender: UIButton) {
        
        if sinceTextfield.isFirstResponder {
            sinceTextfield.text = datePickerView.date.string(format: .ddMMyyyyWithHyphenSeparator)
            sinceTextfield.endEditing(true)
            if let sinceDate = sinceTextfield.text?.getDate(withFormat: .ddMMyyyyWithHyphenSeparator),
                let untilDate = untilTextfield.text?.getDate(withFormat: .ddMMyyyyWithHyphenSeparator) {
                if sinceDate > untilDate {
                    untilTextfield.text = nil
                }
            }
        }
        if untilTextfield.isFirstResponder {
            untilTextfield.text = datePickerView.date.string(format: .ddMMyyyyWithHyphenSeparator)
            untilTextfield.endEditing(true)
        }
        confirmButton.isEnabled = presenter?.requerimentsAreOK(newCustomEvent) ?? false
    }
    
    @objc func datePickerCancel(_ sender: UIButton) {
        if sinceTextfield.isFirstResponder {
            sinceTextfield.endEditing(true)
        }
        if untilTextfield.isFirstResponder {
            untilTextfield.endEditing(true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if #available(iOS 11.0, *) {
                self.confirmViewBottomConstraint.constant = keyboardSize.height
                UIView.animate(withDuration: 1.0,
                               animations: {
                                self.view.layoutIfNeeded()
                })
            } else {
                self.confirmViewBottomConstraint.constant = keyboardSize.height + 10
                UIView.animate(withDuration: 1.0,
                               animations: {
                                self.view.layoutIfNeeded()
                })
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.confirmViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 1.0,
                       animations: {
                        self.view.layoutIfNeeded()                        
        })
    }
    
}

// MARK: -
extension NewCustomEventViewController: StoryBoardInstantiable {
    static func storyboardName() -> String {
        return "NewCustomEvent"
    }
}

// MARK: -
extension NewCustomEventViewController: GlobileDropDownDelegate {
    func dropDownSelected<T>(_ item: GlobileDropdownData<T>, _ sender: GlobileDropdown<T>) {
        if let item = item as? GlobileDropdownData<Frequency> {
            newCustomEvent.frequency = item
            if item.value == Frequency.withoutFrequency {
                if untilTextfield.text != nil, untilTextfield.text != "" {
                    untilTextfield.text = nil
                    
                }
                untilTextfield.isEnabled = false
                newCustomEvent.endDate = nil
            } else {
                untilTextfield.isEnabled = true
            }
            presenter?.setFrequencyIsOK(newCustomEvent)
            confirmButton.isEnabled = presenter?.requerimentsAreOK(newCustomEvent) ?? false
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewCustomEventViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case eventTitleTextfield:
            newCustomEvent.title = eventTitleTextfield.text
        case eventDescriptionTextfield:
            newCustomEvent.description = eventDescriptionTextfield.text
        case sinceTextfield:
            newCustomEvent.startDate = sinceTextfield.text
            setUntilTextField()
            presenter?.setFrequencyIsOK(newCustomEvent)
        case untilTextfield:
            newCustomEvent.endDate = untilTextfield.text
            presenter?.setFrequencyIsOK(newCustomEvent)
        default: break
        }
        
        let requerimentsAreOK = presenter?.requerimentsAreOK(newCustomEvent) ?? false
        confirmButton.isEnabled = requerimentsAreOK
        confirmLabel.isHidden = requerimentsAreOK
    }
    
    @objc func  textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        switch textField {
        case eventTitleTextfield:
            newCustomEvent.title = text
        case eventDescriptionTextfield:
            newCustomEvent.description = text
        default:
            break
        }
        
        let requerimentsAreOK = presenter?.requerimentsAreOK(newCustomEvent) ?? false
        confirmButton.isEnabled = requerimentsAreOK
        confirmLabel.isHidden = requerimentsAreOK
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

// MARK: -
extension NewCustomEventViewController: NewCustomEventViewProtocol {
    
    func setTitle(isNew: Bool) {
        if isNew {
            title = IBLocalizedString("timeline.newcustomeventSection.title")
        } else {
            title = IBLocalizedString("timeline.newcustomeventSection.title.editMode")
        }
    }
    
    func showDatePicker(sender: UITextField) {
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        if sender == sinceTextfield {
            datePickerView.minimumDate = TimeLine.dependencies.configuration?.currentDate ?? Date()
            datePickerView.maximumDate = Calendar.current.date(byAdding: .month,
                                                               value: 3,
                                                               to: TimeLine.dependencies.configuration?.currentDate ?? Date())
        }
        if sender == untilTextfield {
            datePickerView.minimumDate = sinceTextfield.text?.getDate(withFormat: .ddMMyyyyWithHyphenSeparator)
            datePickerView.maximumDate = nil
        }
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(datePickerCancel(_:)))
        let separtor = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDone(_:)))
        toolbar.setItems([cancelButton, separtor, doneButton], animated: false)
        sender.inputAccessoryView = toolbar
        sender.inputView = datePickerView
        view.bringSubviewToFront(datePickerView)
    
    }
    
    func setFrequencyError(_ isFrequencyOK: Bool) {
        if isFrequencyOK {
            frequencyErrorLabel.isHidden = true
        } else {
            frequencyErrorLabel.isHidden = false
        }
    }
    
    func setUntilTextField() {
        if sinceTextfield.text != "", let frequency = newCustomEvent.frequency, frequency.value != Frequency.withoutFrequency {
            untilTextfield.isEnabled = true
        } else if untilTextfield.text != nil, untilTextfield.text != "" {
            untilTextfield.text = nil
            newCustomEvent.endDate = nil
            untilTextfield.isEnabled = false
        }
    }
    
    func loadEventToEdit(event: PeriodicEvent) {
        newCustomEvent.code = event.id
        
        newCustomEvent.title = event.title
        eventTitleTextfield.text = event.title
        
        newCustomEvent.description = event.description
        eventDescriptionTextfield.text = event.description
        
        newCustomEvent.startDate = event.startDate.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyyWithHyphenSeparator)
        sinceTextfield.text = event.startDate.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyyWithHyphenSeparator)
        
        if let date = event.endDate {
            newCustomEvent.endDate = date.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyyWithHyphenSeparator)
            untilTextfield.text = date.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyyWithHyphenSeparator)
        }
        
        switch event.frequency {
        case "00":
            newCustomEvent.frequency = zero
            frequencyDropdown.itemSelected = 0
        case "01":
            newCustomEvent.frequency = weekly
            frequencyDropdown.itemSelected = 1
        case "02":
            newCustomEvent.frequency = twoWeeks
            frequencyDropdown.itemSelected = 2
        case "03":
            newCustomEvent.frequency = monthly
            frequencyDropdown.itemSelected = 3
        case "04":
            newCustomEvent.frequency = annually
            frequencyDropdown.itemSelected = 4
        default:
            newCustomEvent.frequency = zero
            frequencyDropdown.itemSelected = 0
        }
    }
}


extension NewCustomEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let tappedLocation = gestureRecognizer.location(in: self.view)
        if view.hitTest(tappedLocation, with: nil) as? GlobileEndingButton != nil {
            return false
        } else {
            return true
        }
    }

}
