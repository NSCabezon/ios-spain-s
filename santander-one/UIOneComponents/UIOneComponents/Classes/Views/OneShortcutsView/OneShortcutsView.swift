//
//  OneShortcutsView.swift
//  UIOneComponents
//
//  Created by Laura Gonzalez Salvador on 7/3/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import UI

public enum OneShortcutsViewStates: State {
    case didTapMoreOptions
}

private enum LayoutConstants {
    static let moreOptionsVisibleHeight: CGFloat = 144
    static let moreOptionsHiddenHeight: CGFloat = 112
    static let moreOptionsHiddenTop: CGFloat = -16
    static let singleButtonHeight: CGFloat = 88
}

final public class OneShortcutsView: XibView {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var gradientView: OneGradientView!
    @IBOutlet private weak var moreOptionsView: UIView!
    @IBOutlet private weak var oneOvalButton: OneOvalButton!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var moreOptionsViewTop: NSLayoutConstraint!
    @IBOutlet private weak var oneOvalButtonTop: NSLayoutConstraint!

    private var subject = PassthroughSubject<OneShortcutsViewStates, Never>()
    public lazy var publisher: AnyPublisher<OneShortcutsViewStates, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    @IBAction func moreOptionsButtonDidTapped(_ sender: Any) {
        publishTap()
    }
}

public extension OneShortcutsView {
    func addButtons(buttons: [OneShortcutButtonConfiguration]) {
        guard buttons.isNotEmpty else { return }
        if buttons.count == 1 {
            addButton(config: buttons.first ?? nil, hasHorizontalStyle: true)
            containerViewHeight.constant = LayoutConstants.singleButtonHeight
        } else {
            for button in buttons {
                addButton(config: button, hasHorizontalStyle: false)
            }
            containerViewHeight.constant = LayoutConstants.moreOptionsVisibleHeight
        }
    }
    
    func removeButtons() {
        self.buttonsStackView.removeAllArrangedSubviews()
    }
    
    func hideMoreOptionsButton() {
        moreOptionsView.isHidden = true
        oneOvalButton.isHidden = true
        containerViewHeight.constant = LayoutConstants.moreOptionsHiddenHeight
        moreOptionsViewTop.constant = LayoutConstants.moreOptionsHiddenTop
        oneOvalButtonTop.constant = LayoutConstants.moreOptionsHiddenTop
    }

    func showMoreOptionsButton() {
        moreOptionsView.isHidden = false
        oneOvalButton.isHidden = false
        containerViewHeight.constant = LayoutConstants.moreOptionsVisibleHeight
    }
    
    func setupMoreOptionsAccessibility(key: String) {
        oneOvalButton.setAccessibilityIdentifier(key: key)
    }
}

private extension OneShortcutsView {
    func setupView() {
        backgroundColor = .white
        setGradient()
        setMoreOptionsView()
    }
    
    func setGradient() {
        gradientView.setupType(.oneGrayGradient(direction: .bottomToTop))
    }
    
    func setMoreOptionsView() {
        moreOptionsView.backgroundColor = .oneSkyGray
        oneOvalButton.backgroundColor = .clear
        oneOvalButton.size = .small
        oneOvalButton.style = .whiteWithTurquoiseTint
        oneOvalButton.direction = .plus
        oneOvalButton.isEnabled = true
        moreOptionsView.layer.cornerRadius = moreOptionsView.layer.bounds.width / 2
        moreOptionsView.clipsToBounds = true
    }
    
    func addButton(config: OneShortcutButtonConfiguration?, hasHorizontalStyle: Bool) {
        guard let config = config else { return }
        let button = OneShortcutButton()
        button.setViewModel(configuration: config, hasHorizontalStyle: hasHorizontalStyle)
        button.setAccessibilitySuffix(config.accessibilitySuffix)
        buttonsStackView.addArrangedSubview(button)
    }

    func publishTap() {
        subject.send(.didTapMoreOptions)
    }
}
