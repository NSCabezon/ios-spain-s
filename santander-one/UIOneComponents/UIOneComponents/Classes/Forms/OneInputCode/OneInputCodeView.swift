//
//  OneInputCodeView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 25/2/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine

// Reactive
public protocol ReactiveOneInputCodeView {
    var publisher: AnyPublisher<ReactiveOneInputCodeViewState, Never> { get }
}

public enum ReactiveOneInputCodeViewState: State {
    case didChange(_ view: OneInputCodeView, string: String, position: Int, allValues: [String])
    case willChange(_ view: OneInputCodeView, string: String, position: Int)
    case didBeginEditing(_ view: OneInputCodeView, position: Int)
    case didEndEditing(_ view: OneInputCodeView, position: Int)
}

public protocol OneInputCodeViewDelegate: AnyObject {
    func inputCodeView(_ view: OneInputCodeView, didChange string: String, for position: Int)
    func inputCodeView(_ view: OneInputCodeView, willChange string: String, for position: Int)
    func inputCodeView(_ view: OneInputCodeView, didBeginEditing position: Int)
    func inputCodeView(_ view: OneInputCodeView, didEndEditing position: Int)
}

public final class OneInputCodeView: UIView {
    private enum Constants {
        enum VerticalStackView {
            static let spacing: CGFloat = 20.0
        }
        enum ChangeVisibilityButton {
            static let normalColor: UIColor = .oneDarkTurquoise
            static let highLightedColor: UIColor = .oneTurquoise
            static let font: UIFont = .typography(fontName: .oneB300Bold)
            enum Show {
                static let titleKey: String = "generic_link_show"
                static let imageName: String = "oneIcnEye"
            }
            enum Hide {
                static let titleKey: String = "generic_link_hide"
                static let imageName: String = "oneIcnEyeClose"
            }
            enum Constraints {
                static let semanticContent: UISemanticContentAttribute = .forceRightToLeft
                static let imageContentMode: UIView.ContentMode = .scaleAspectFit
                static let imageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: .zero, left: 8.0, bottom: .zero, right: .zero)
            }
        }
    }
    
    // Reactive
    private let stateSubject = PassthroughSubject<ReactiveOneInputCodeViewState, Never>()
    
    weak var delegate: OneInputCodeViewDelegate?
    private var inputCodeBoxes = [OneInputCodeBoxView]()
    private var viewModel: OneInputCodeViewModel? {
        didSet {
            self.setupView()
        }
    }
    private var hiddenCharacters: Bool = true {
        didSet {
            self.updateChangeVisibilityButton()
        }
    }
    private lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    private lazy var mainStackView: UIStackView = {
        let verticalStackView = UIStackView(arrangedSubviews: [self.boxesStackView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = Constants.VerticalStackView.spacing
        verticalStackView.distribution = .fill
        verticalStackView.alignment = .center
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        if let viewModel = self.viewModel, viewModel.enabledChangeVisibility {
            verticalStackView.addArrangedSubview(self.changeVisibilityButton)
        }
        return verticalStackView
    }()
    private lazy var boxesStackView: UIStackView = {
        let boxesStackView = UIStackView()
        boxesStackView.axis = .horizontal
        boxesStackView.spacing = OneInputCodeBoxView.Constants.spacing
        boxesStackView.distribution = .fillEqually
        boxesStackView.translatesAutoresizingMaskIntoConstraints = false
        for position in .zero..<self.inputCodeBoxes.count {
            boxesStackView.addArrangedSubview(self.inputCodeBoxes[position])
        }
        return boxesStackView
    }()
    private lazy var changeVisibilityButton: UIButton = {
        let changeVisibilityButton = UIButton()
        changeVisibilityButton.setTitleColor(Constants.ChangeVisibilityButton.normalColor, for: .normal)
        changeVisibilityButton.setTitleColor(Constants.ChangeVisibilityButton.highLightedColor, for: .highlighted)
        changeVisibilityButton.titleLabel?.font = Constants.ChangeVisibilityButton.font
        changeVisibilityButton.semanticContentAttribute = Constants.ChangeVisibilityButton.Constraints.semanticContent
        changeVisibilityButton.imageView?.contentMode = Constants.ChangeVisibilityButton.Constraints.imageContentMode
        changeVisibilityButton.imageEdgeInsets = Constants.ChangeVisibilityButton.Constraints.imageEdgeInsets
        changeVisibilityButton.addTarget(self, action: #selector(toggleVisibility), for: .touchUpInside)
        return changeVisibilityButton
    }()
    
    @discardableResult override public func resignFirstResponder() -> Bool {
        let _ = self.inputCodeBoxes.isAnyFirstResponder()?.resignFirstResponder()
        return true
    }
    
    @discardableResult public override func becomeFirstResponder() -> Bool {
        guard let first = self.inputCodeBoxes.firstEmptyRequested() else { return false }
        return first.becomeFirstResponder()
    }
    
    public init(with viewModel: OneInputCodeViewModel, delegate: OneInputCodeViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.setViewModel(viewModel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setViewModel(_ viewModel: OneInputCodeViewModel) {
        self.hiddenCharacters = viewModel.hiddenCharacters
        self.viewModel = viewModel
    }
    
    public func fulfilledText() -> String? {
        return self.inputCodeBoxes.fulfilledText()
    }
    
    public func isFulfilled() -> Bool {
        return self.inputCodeBoxes.fulfilledCount() == self.inputCodeBoxes.requestedCount()
    }
    
    public func reset() {
        self.inputCodeBoxes.reset()
    }
    
    public func enableError() {
        self.reset()
        self.inputCodeBoxes.enableError()
    }
    
    public func disableError() {
        self.inputCodeBoxes.disableError()
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension OneInputCodeView {
    func setupView() {
        self.configureInputCodeBoxes()
        self.addSubviews()
        self.setAccessibilityIdentifiers()
    }
    
    func configureInputCodeBoxes() {
        guard let viewModel = self.viewModel else { return }
        for position in 0..<viewModel.itemsCount {
            self.inputCodeBoxes.append(OneInputCodeBoxView(with: OneInputCodeBoxViewModel(itemsCount: viewModel.itemsCount,
                                                                                          position: position,
                                                                                          requested: viewModel.requestedPositions.isRequestedPosition(position: position),
                                                                                          hidden: self.hiddenCharacters),
                                                           delegate: self))
        }
    }
    
    func addSubviews() {
        self.container.addSubview(self.mainStackView)
        NSLayoutConstraint.activate([
            self.mainStackView.widthAnchor.constraint(equalToConstant: self.getControlLength()),
            self.boxesStackView.heightAnchor.constraint(equalToConstant: OneInputCodeBoxView.Constants.size.height),
            self.mainStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            self.mainStackView.topAnchor.constraint(equalTo: container.topAnchor),
            self.mainStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        self.addSubview(self.container)
        NSLayoutConstraint.activate([
            self.container.topAnchor.constraint(equalTo: self.topAnchor),
            self.container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.container.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.container.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func getControlLength() -> CGFloat {
        guard let viewModel = self.viewModel else { return .zero }
        let boxesLength = CGFloat(viewModel.itemsCount) * OneInputCodeBoxView.Constants.size.width
        let spaceLength = 2.0 * CGFloat(viewModel.itemsCount - 1)
        let controlLength = boxesLength + spaceLength
        return CGFloat(controlLength)
    }
    
    @objc func toggleVisibility(_ sender: UIButton) {
        self.hiddenCharacters.toggle()
        self.inputCodeBoxes.toggleVisibility()
    }
    
    func updateChangeVisibilityButton() {
        let title: String = localized(self.hiddenCharacters ? Constants.ChangeVisibilityButton.Show.titleKey : Constants.ChangeVisibilityButton.Hide.titleKey)
        let image: UIImage? = Assets.image(named: self.hiddenCharacters ? Constants.ChangeVisibilityButton.Show.imageName : Constants.ChangeVisibilityButton.Hide.imageName)?.withRenderingMode(.alwaysTemplate)
        self.changeVisibilityButton.setTitle(title, for: .normal)
        self.changeVisibilityButton.setImage(image?.tinted(WithColor: Constants.ChangeVisibilityButton.normalColor, scale: .zero), for: .normal)
        self.changeVisibilityButton.setImage(image?.tinted(WithColor: Constants.ChangeVisibilityButton.highLightedColor, scale: .zero), for: .highlighted)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String = "") {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneInputCodeView + suffix
        self.changeVisibilityButton.titleLabel?.accessibilityIdentifier = AccessibilityOneComponents.oneInputCodeLink + suffix
        self.changeVisibilityButton.imageView?.accessibilityIdentifier = AccessibilityOneComponents.oneInputCodeIcon + suffix
    }
    
    func becomeFirstResponderAsync(_ codeBoxView: OneInputCodeBoxView) {
        DispatchQueue.main.async {
            let _ = codeBoxView.becomeFirstResponder()
        }
    }
    
    func resignFirstResponderAsync(_ codeBoxView: OneInputCodeBoxView) {
        DispatchQueue.main.async {
            let _ = codeBoxView.resignFirstResponder()
        }
    }
}

extension OneInputCodeView: OneInputCodeBoxViewDelegate {
    func codeBoxViewShouldChangeString(_ codeBoxView: OneInputCodeBoxView, replacementString string: String) -> Bool {
        guard !string.trimed.isEmpty,
              let viewModel = viewModel,
              let character = UnicodeScalar(string) else {
            codeBoxView.text = ""
                  let allValues = self.inputCodeBoxes.allValuesText()
                  self.stateSubject.send(.didChange(self, string: string, position: codeBoxView.position, allValues: allValues))
            return false
        }
        guard !string.isBackSpace else { return true }
        if viewModel.isAlphanumeric {
           if !CharacterSet.alphanumerics.contains(character) {
               return false
           }
        } else if !CharacterSet.numbers.contains(character) {
            return false
        }
        self.delegate?.inputCodeView(self, willChange: string, for: codeBoxView.position)
        self.stateSubject.send(.willChange(self, string: string, position: codeBoxView.position))
        codeBoxView.text = string
        self.delegate?.inputCodeView(self, didChange: string, for: codeBoxView.position)
        let allValues = self.inputCodeBoxes.allValuesText()
        self.stateSubject.send(.didChange(self, string: string, position: codeBoxView.position, allValues: allValues))
        if let nextPasswordInputBoxView = self.inputCodeBoxes.nextEmptyRequested(from: codeBoxView.position) {
            self.becomeFirstResponderAsync(nextPasswordInputBoxView)
        } else {
            self.resignFirstResponderAsync(codeBoxView)
        }
        return false
    }
    
    func codeBoxViewDidBeginEditing(_ codeBoxView: OneInputCodeBoxView) {
        self.disableError()
        guard codeBoxView.isEmpty,
              let firstEmptyRequested = self.inputCodeBoxes.firstEmptyRequested(),
              firstEmptyRequested != codeBoxView else {
                  guard let viewModel = self.viewModel else { return }
                  codeBoxView.keyboardType = viewModel.isAlphanumeric ? .default : .numberPad
                  self.becomeFirstResponderAsync(codeBoxView)
                  self.delegate?.inputCodeView(self, didBeginEditing: codeBoxView.position)
                  self.stateSubject.send(.didBeginEditing(self, position: codeBoxView.position))
                  return
              }
        self.becomeFirstResponderAsync(firstEmptyRequested)
    }
    
    func codeBoxViewDidEndEditing(_ codeBoxView: OneInputCodeBoxView) {
        self.resignFirstResponderAsync(codeBoxView)
        self.delegate?.inputCodeView(self, didEndEditing: codeBoxView.position)
        self.stateSubject.send(.didEndEditing(self, position: codeBoxView.position))
    }
    
    func codeBoxViewDidDelete(_ codeBoxView: OneInputCodeBoxView, goToPrevious: Bool) {
        self.delegate?.inputCodeView(self, didChange: codeBoxView.text ?? "", for: codeBoxView.position)
        let allValues = self.inputCodeBoxes.allValuesText()
        self.stateSubject.send(.didChange(self, string: codeBoxView.text ?? "", position: codeBoxView.position, allValues: allValues))
        if goToPrevious, let previousBoxView = self.inputCodeBoxes.previousRequested(from: codeBoxView.position) {
            self.becomeFirstResponderAsync(previousBoxView)
        }
    }
}

extension OneInputCodeView: ReactiveOneInputCodeView {
    public var publisher: AnyPublisher<ReactiveOneInputCodeViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

fileprivate extension Array where Element == OneInputCodeBoxView {
    func nextEmptyRequested(from position: NSInteger) -> OneInputCodeBoxView? {
        guard position >= .zero, position < self.count else { return nil }
        return self.first { $0.requested && $0.position >= position && $0.isEmpty }
    }

    func previousRequested(from position: NSInteger) -> OneInputCodeBoxView? {
        guard position > .zero, position <= self.count else { return nil }
        return self.last { $0.requested && $0.position < position }
    }

    func firstEmptyRequested() -> OneInputCodeBoxView? {
        return self.first { $0.requested && $0.isEmpty }
    }

    func isAnyFirstResponder() -> OneInputCodeBoxView? {
        return self.first { $0.isFirstResponder }
    }

    func fulfilledBoxViews() -> [OneInputCodeBoxView]? {
        return self.filter { return $0.requested && !$0.isEmpty }
    }

    func fulfilledText() -> String? {
        guard let fullfilledInputBoxArray = self.fulfilledBoxViews() else { return nil }
        return fullfilledInputBoxArray.reduce("", { result, inputBox in
            return result + (inputBox.text ?? "")
        })
    }
    
    func allValuesText() -> [String] {
        guard let fullfilledInputBoxArray = self.fulfilledBoxViews() else { return [] }
        let allValuesText: [String] = fullfilledInputBoxArray.compactMap { inputBox in
            guard inputBox.text != "" else {
                return nil
            }
            return inputBox.text
        }
        return allValuesText
    }

    func fulfilledCount() -> Int {
        guard let fulfilledInputBoxArray = self.fulfilledBoxViews() else { return 0 }
        return fulfilledInputBoxArray.count
    }

    func requestedCount() -> Int {
        return self.filter { $0.requested == true }.count
    }

    func reset() {
        guard let fullfilledInputBoxArray = self.fulfilledBoxViews() else { return }
        fullfilledInputBoxArray.forEach { $0.text = "" }
    }
    
    func toggleVisibility() {
        self.forEach { $0.isSecureText.toggle() }
    }
    
    func enableError() {
        self.forEach { $0.status = .error }
    }
    
    func disableError() {
        self.forEach { $0.status = .deselected }
    }
}
