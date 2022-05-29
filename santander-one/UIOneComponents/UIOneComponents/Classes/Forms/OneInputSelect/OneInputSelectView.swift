//
//  OneInputSelect.swift
//  UIOneComponents
//
//  Created by Daniel Gómez Barroso on 21/9/21.
//

import UI
import CoreFoundationLib
import UIKit

public protocol OneInputSelectViewDelegate: AnyObject {
    func didSelectOneItem(_ index: Int)
}

public final class OneInputSelectView: XibView {
    private struct Constants {
        static let datePickerWidth: CGFloat = UIScreen.main.bounds.width
        static let datePickerHeight: CGFloat = 216
    }
    
    @IBOutlet private weak var inputOptionField: ConfigurableActionsTextField!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var dropDownImage: UIImageView!
    @IBOutlet private weak var borderContentView: UIView!
    @IBOutlet private weak var warningImage: UIImageView!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var warningStackView: UIStackView!
    @IBOutlet weak var selectedOptionButton: UIButton!
    public weak var delegate: OneInputSelectViewDelegate?
    private var viewModel: OneInputSelectViewModel?
    public var status: OneStatus? {
        didSet {
            self.updateByStatus()
        }
    }
    private var picker: UIPickerView?
    private var pickerData: [String]?
    private var previousPick: Int?
    private var selectedInput: Int?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public init(with viewModel: OneInputSelectViewModel) {
        super.init(frame: .zero)
        self.configureView()
        self.setViewModel(viewModel)
    }
    
    public func setViewModel(_ viewModel: OneInputSelectViewModel) {
        self.viewModel = viewModel
        self.selectedInput = viewModel.selectedInput
        self.configureByStatus(viewModel)
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public func updateTextfield( with string: String) {
        self.inputOptionField.text = string
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    public func setOneStatus(_ status: OneStatus) {
        self.status = status
        if status == .activated || status == .focused {
            self.previousPick = self.selectedInput
        }
    }
    
    public func shouldShowOption() -> Bool {
        return self.status == .activated || self.status == .focused
    }
    
    public func shouldShowErrorMessage() -> Bool {
        return self.status == .error
    }
}

private extension OneInputSelectView {
    func configureView() {
        self.setRadius()
        self.configureInputOptionField()
        self.configureLabels()
        self.configurePicker()
        self.configureImages()
        self.setAccessibilityIdentifiers()
    }

    func configureByStatus(_ viewModel: OneInputSelectViewModel) {
        self.setInputTexts(with: viewModel)
        self.setLabelTexts(with: viewModel)
        self.pickerData = viewModel.pickerData
        self.status = viewModel.status
        self.updateInputOptionField()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func updateByStatus() {
        self.updateBorderContentView()
        self.updateInputOptionFieldStatus()
        self.updateImage()
        self.updateWarningStackView()
    }
    
    func setRadius() {
        self.borderContentView.setOneCornerRadius(type: .oneShRadius8)
    }
    
    func configureInputOptionField() {
        self.inputOptionField.borderStyle = .none
        self.inputOptionField.font = .typography(fontName: .oneH100Regular)
        self.inputOptionField.setDisabledActions(TextFieldActions.usuallyDisabledActions)
        self.inputOptionField.tintColor = .clear
        self.inputOptionField.delegate = self
        self.inputOptionField.placeholder = ""
        self.inputOptionField.isUserInteractionEnabled = true
    }
    
    func configureLabels() {
        self.infoLabel.font = .typography(fontName: .oneB200Bold)
        self.infoLabel.textColor = .oneDarkTurquoise
        self.warningLabel.font = .typography(fontName: .oneB300Regular)
        self.warningLabel.textColor = .oneSantanderRed
    }
    
    func configurePicker() {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: Constants.datePickerWidth, height: Constants.datePickerHeight))
        let toolBar = self.getPickerToolbar()
        self.inputOptionField.inputView = picker
        self.inputOptionField.inputAccessoryView = toolBar
        picker.delegate = self
        picker.dataSource = self
        self.picker = picker
    }
    
    func configureImages() {
        self.dropDownImage.image = Assets.image(named: "icnArrowDownNoRound")
        self.warningImage.image = Assets.image(named: "icnAlert")
    }
    
    func setLabelTexts(with viewModel: OneInputSelectViewModel) {
        self.infoLabel.text = localized(viewModel.infoLabelKey ?? "")
        if let wargingKey = viewModel.warningKey {
            self.warningLabel.text = wargingKey
        }
    }
    
    func setInputTexts(with viewModel: OneInputSelectViewModel) {
        if let selectedInput = viewModel.selectedInput {
            self.inputOptionField.text = localized(viewModel.pickerData[selectedInput])
        }
        self.inputOptionField.attributedPlaceholder = NSAttributedString(string: localized(viewModel.placeholderKey ?? ""),
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.oneLisboaGray.withAlphaComponent(0.5)])
    }
    
    func updateBorderContentView() {
        self.borderContentView.drawBorder(color: self.borderColor)
        self.borderContentView.setOneShadows(type: self.shadowStyle)
        self.borderContentView.backgroundColor = self.backGroundColor
    }
    
    func updateInputOptionFieldStatus() {
        self.inputOptionField.textColor = self.selectedInputLabelColor
    }
    
    func updateImage() {
        self.dropDownImage.image = Assets.image(named: self.dropDownImageLiteral)
        self.dropDownImage.image = self.dropDownImage.image?.withRenderingMode(.alwaysTemplate)
        self.dropDownImage.tintColor = self.dropDownImageColor
    }
    
    func updateWarningStackView() {
        self.warningStackView.isHidden = !self.shouldShowErrorMessage()
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectView + (suffix ?? "")
        self.inputOptionField.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectText + (suffix ?? "")
        self.infoLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectInfo + (suffix ?? "")
        self.dropDownImage.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectRightIcn + (suffix ?? "")
        self.warningLabel.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectAlertText + (suffix ?? "")
        self.warningImage.accessibilityIdentifier = AccessibilityOneComponents.oneInputSelectAlertIcn + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.inputOptionField.isAccessibilityElement = false
        self.selectedOptionButton.accessibilityLabel = self.inputOptionField.text
    }
    
    func resetPickerToLastInput() {
        guard let picker = self.inputOptionField.inputView as? UIPickerView else { return }
        if let previousPick = self.previousPick {
            picker.selectRow(previousPick, inComponent: 0, animated: false)
            self.selectedInput = previousPick
        } else {
            self.status = .inactive
        }
        self.updateInputOptionField()
    }
    
    func getPickerToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = .oneDarkTurquoise
        toolBar.backgroundColor = .oneSkyGray
        toolBar.sizeToFit()
        let buttons = self.getToolbarButtons()
        toolBar.setItems(buttons, animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    func getToolbarButtons() -> [UIBarButtonItem] {
        let doneButton = UIBarButtonItem(title: localized("generic_button_accept"), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: localized("generic_button_cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPressed))
        doneButton.setTitleTextAttributes([.foregroundColor: UIColor.oneDarkTurquoise], for: [.normal, .highlighted])
        cancelButton.setTitleTextAttributes([.foregroundColor: UIColor.oneDarkTurquoise], for: [.normal, .highlighted])
        return [cancelButton, spaceButton, doneButton]
    }
    
    func updateInputOptionField() {
        guard let index = self.selectedInput,
              let pickerData = self.pickerData,
              self.shouldShowOption(),
              let _ = self.inputOptionField.inputView as? UIPickerView  else { return }
        self.inputOptionField.text = localized(pickerData[index])
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.previousPick = index
    }
    
    @objc func cancelPressed() {
        self.inputOptionField.endEditing(false)
    }
    
    @objc func doneButtonPressed() {
        guard let pickerData = self.pickerData,
              let selectedRow = self.picker?.selectedRow(inComponent: 0) else { return }
        self.inputOptionField.text = pickerData[selectedRow]
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.selectedInput = selectedRow
        self.updateInputOptionField()
        self.previousPick = self.selectedInput
        self.inputOptionField.resignFirstResponder()
        self.delegate?.didSelectOneItem(selectedRow)
    }
    
    @IBAction func didTapOnOnePicker(_ sender: Any) {
        guard let type = self.viewModel?.type else { return }
        switch type {
        case .picker:
            self.inputOptionField.becomeFirstResponder()
            UIAccessibility.post(notification: .screenChanged, argument: self.picker)
        case .bottomSheet(let view, let type):
            guard let viewController = self.parentContainerViewController() else { return }
            BottomSheet().show(in: viewController,
                               type: self.getSizableFromSize(type),
                               component: .all,
                               view: view)
        }
    }
    
    func getSizableFromSize(_ size: OneInputSelectType.BottomSheetSize) -> SizablePresentationType {
        switch size {
        case .top: return .top(isPan: true, bottomVisible: true, tapOutsideDismiss: true)
        case .auto: return .custom(isPan: true, bottomVisible: true, tapOutsideDismiss: true)
        }
    }
}

extension OneInputSelectView {
    var backGroundColor: UIColor {
        let status = self.status ?? .disabled
        switch status {
        case .inactive, .activated, .error, .focused: return .oneWhite
        case .disabled: return .oneLightGray40
        }
    }
    
    var borderColor: UIColor {
        let status = self.status ?? .disabled
        switch status {
        case .inactive, .activated: return .oneBrownGray
        case .focused: return .oneDarkTurquoise
        case .disabled: return .oneBrownGray
        case .error: return .oneBostonRed
        }
    }
    
    var shadowStyle: OneShadowsType {
        let status = self.status ?? .disabled
        switch status {
        case .inactive, .activated, .focused, .error: return .oneShadowSmall
        case .disabled: return .none
        }
    }
    
    var selectedInputLabelColor: UIColor {
        let status = self.status ?? .disabled
        switch status {
        case .activated, .focused, .error: return .oneLisboaGray
        case .inactive, .disabled: return .oneBrownishGray
        }
    }
    
    var dropDownImageLiteral: String {
        let status = self.status ?? .disabled
        switch status {
        case .inactive, .activated, .error, .disabled: return "icnArrowDownNoRound"
        case .focused: return "icnArrowUpNoRound"
        }
    }
    
    var dropDownImageColor: UIColor {
        switch self.status {
        case .inactive, .activated, .focused, .error: return .oneDarkTurquoise
        case .disabled: return .oneBrownishGray
        case .none: return .oneBrownishGray
        }
    }
}

extension OneInputSelectView: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let pickerData = self.pickerData else { return 0 }
        return pickerData.count
    }
    
    public func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let pickerData = self.pickerData else { return nil }
        return localized(pickerData[row])
    }
}

extension OneInputSelectView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.status = .focused
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard self.status != .disabled else { return false }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let input = self.inputOptionField.text,
              self.checkInput(input)
        else {
            self.status = .inactive
            self.resetPickerToLastInput()
            return
        }
        self.status = .activated
        self.resetPickerToLastInput()
    }
    
    public func checkInput(_ input: String) -> Bool {
        guard let pickerData = self.pickerData else { return false }
        return pickerData.contains(input)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension OneInputSelectView: OneComponentStatusProtocol {
    public func showError(_ error: String?) {
        self.warningLabel.text = error
        self.status = .error
    }
    
    public func hideError() {
        self.status = .activated
    }
}

extension OneInputSelectView: AccessibilityCapable {}
