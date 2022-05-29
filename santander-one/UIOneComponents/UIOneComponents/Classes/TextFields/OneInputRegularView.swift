//
//  OneInputRegular.swift
//  UIOneComponents
//
//  Created by David Gálvez Alonso on 21/9/21.
//

import UI
import CoreFoundationLib
import OpenCombine

public protocol OneInputRegularViewDelegate: AnyObject {
    func textDidChange(_ text: String)
    func shouldReturn()
    func didEndEditing(_ view: OneInputRegularView)
}

public extension OneInputRegularViewDelegate {
    func didEndEditing(_ view: OneInputRegularView) { }
}

public protocol OneInputRegularCharactersDelegate: AnyObject {
    func updateNumberOfCharacters(_ total: Int)
}

// Reactive
public protocol ReactiveOneInputRegularView {
    var publisher: AnyPublisher<ReactiveOneInputRegularViewState, Never> { get }
}
public enum ReactiveOneInputRegularViewState: State {
    case textDidChange(String)
    case shouldReturn
    case didEndEditing
}

public final class OneInputRegularView: XibView {

    // Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneInputRegularViewState, Never>()

    
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var leftImageContainerView: UIView!
    @IBOutlet private weak var rightImageContainerView: UIView!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
        
    private var searchAction: (() -> Void)?
    private var resetText: Bool = false
    public var maxCounter: Int?
    public weak var delegate: OneInputRegularViewDelegate?
    public weak var charactersDelegate: OneInputRegularCharactersDelegate?
    public var regularExpression: NSRegularExpression?

    public init() {
        super.init(frame: .zero)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    public func setupTextField(_ viewModel: OneInputRegularViewModel) {
        self.searchAction = viewModel.searchAction
        self.resetText = viewModel.resetText
        self.configureViewState(viewModel.status)
        self.inputTextField.text = viewModel.text
        self.inputTextField.attributedPlaceholder = NSAttributedString(string: localized(viewModel.placeholder ?? ""),
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.oneLisboaGray.withAlphaComponent(0.5)])
        self.configureAlignment(viewModel: viewModel)
        self.configureTextSize(viewModel: viewModel)
        self.configureTextContentType(viewModel: viewModel)
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    public func getInputText() -> String? {
        return self.inputTextField.text
    }
    
    public func isTextFieldEmpty() -> Bool {
        return self.inputTextField.text?.isEmpty ?? true
    }
    
    public func setInputText(_ text: String?) {
        self.inputTextField.text = text
    }
    
    public override func becomeFirstResponder() -> Bool {
        self.inputTextField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }
}

private extension OneInputRegularView {
    func configureView() {
        self.configureViews()
        self.configureTextField()
        self.configureRightImageView()
        self.setAccessibilityIdentifiers()
    }
    
    func configureViews() {
        self.setOneCornerRadius(type: .oneShRadius8)
        self.layer.borderWidth = 1
        self.leftImageContainerView.isUserInteractionEnabled = true
        self.leftImageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftImageContainerViewDidPressed)))
        self.rightImageContainerView.isUserInteractionEnabled = true
        self.rightImageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightImageContainerViewDidPressed)))
    }
    
    func configureTextField() {
        self.inputTextField.tintColor = UIColor.oneBrownishGray
        self.inputTextField.font = UIFont.typography(fontName: .oneH100Regular)
        self.inputTextField.delegate = self
        self.inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func configureRightImageView() {
        self.leftImageView.image = Assets.image(named: "icnOneSearch")
        self.rightImageView.image = Assets.image(named: "icnOneCloseOval")
    }
    
    @objc func rightImageContainerViewDidPressed() {
        self.inputTextField.text = nil
        self.setRightImageVisibility(visible: true)
        self.textFieldDidChange()
        if self.maxCounter != nil {
            self.charactersDelegate?.updateNumberOfCharacters(self.inputTextField.text?.count ?? 0)
        }
    }
    
    @objc func leftImageContainerViewDidPressed() {
        self.searchAction?()
    }
    
    @objc func textFieldDidChange() {
        self.delegate?.textDidChange(self.inputTextField.text ?? "")
        self.charactersDelegate?.updateNumberOfCharacters(self.inputTextField.text?.count ?? 0)

        stateSubject.send(.textDidChange(self.inputTextField.text ?? ""))
    }
    
    func configureViewState(_ status: OneInputRegularViewModel.Status) {
        self.leftImageContainerView.isHidden = self.searchAction == nil
        self.setRightImageVisibility(visible: status != .focused)
        self.setOneShadows(type: status == .disabled ? .none : .oneShadowSmall)
        self.backgroundColor = status == .disabled ? UIColor.oneLightGray40 : .white
        self.inputTextField.textColor = status == .disabled ? UIColor.oneBrownishGray : UIColor.oneLisboaGray
        self.inputTextField.isEnabled = status != .disabled
        switch status {
        case .inactive, .activated:
            self.layer.borderColor = UIColor.oneBrownGray.cgColor
        case .focused:
            self.layer.borderColor = UIColor.oneDarkTurquoise.cgColor
        case .disabled:
            self.layer.borderColor = UIColor.clear.cgColor
        case .error:
            self.layer.borderColor = UIColor.oneBostonRed.cgColor
        }
    }
    
    func setRightImageVisibility(visible: Bool) {
        self.rightImageContainerView.isHidden = !self.resetText ? true : visible
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneInputRegularView + (suffix ?? "")
        self.inputTextField.accessibilityIdentifier = AccessibilityOneComponents.oneInputRegularTextField + (suffix ?? "")
        self.leftImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputRegularSearchIcn + (suffix ?? "")
        self.rightImageView.accessibilityIdentifier = AccessibilityOneComponents.oneInputRegularClearIcn + (suffix ?? "")
    }
    
    func configureTextSize(viewModel: OneInputRegularViewModel) {
        if case .large = viewModel.textSize {
            self.inputTextField.font = .typography(fontName: .oneH500Regular)
        }
    }
    
    func configureAlignment(viewModel: OneInputRegularViewModel) {
        if case .center = viewModel.alignment {
            self.inputTextField.textAlignment = .center
        }
    }
    
    func configureTextContentType(viewModel: OneInputRegularViewModel) {
        if case .otp = viewModel.textContentType, #available(iOS 12.0, *) {
            self.inputTextField.textContentType = .oneTimeCode
        }
    }
}

extension OneInputRegularView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.configureViewState(.focused)
        self.setRightImageVisibility(visible: textField.text?.isEmpty != false)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.configureViewState(.activated)
        self.delegate?.didEndEditing(self)
        stateSubject.send(.didEndEditing)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.configureViewState(.activated)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.shouldReturn()
        stateSubject.send(.shouldReturn)
        self.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let replacingText = currentText.replacingCharacters(in: range, with: string)
        self.setRightImageVisibility(visible: replacingText.isEmpty)
        guard let maxLength = self.maxCounter else {
            return true
        }
        let matchRegularExpression = string.matchRegularExpression(self.regularExpression)
        return (replacingText as NSString).length <= maxLength && matchRegularExpression
    }
}

extension OneInputRegularView: ReactiveOneInputRegularView {

    public var publisher: AnyPublisher<ReactiveOneInputRegularViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

private extension String {
    func matchRegularExpression(_ regularExpression: NSRegularExpression?) -> Bool {
        guard let regex = regularExpression else { return true }
        return self.match(regex:regex) || self == ""
    }
}
