//
//  InternalTransferDescriptionView.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 24/2/22.
//

import UIOneComponents
import CoreFoundationLib
import OpenCombine

public protocol ReactiveInternalTransferDescriptionView {
    var publisher: AnyPublisher<InternalTransferDescriptionViewState, Never> { get }
}
public enum InternalTransferDescriptionViewState: State {
    case descriptionDidChange(_ text: String)
}

final class InternalTransferDescriptionView: UIView {

    private let oneLabelDescriptionView = OneLabelView(frame: .zero)
    private let oneTextFieldView = OneInputRegularView()
    private var subscriptions: Set<AnyCancellable> = []
    private let stateSubject = PassthroughSubject<InternalTransferDescriptionViewState, Never>()

    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        bind()
        addDescriptionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDescription(_ description: String?) {
        guard let description = description else { return }
        oneTextFieldView.setInputText(description)
        oneLabelDescriptionView.setActualCounterLabel(String(description.count))
    }

    func configureView(maxCounterLabel: String, regularExpression: NSRegularExpression?) {
        let oneLabelViewModel = OneLabelViewModel(type: .counter,
                                                  mainTextKey: localized("sendMoney_label_description"),
                                                  maxCounterLabel: maxCounterLabel,
                                                  accessibilitySuffix: AccessibilitySendMoneyAmount.descriptionSuffix,
                                                  counterLabelsAccessibilityText: localized("voiceover_numberTotalCharacters",
                                                                                            [.init(.number, "0"), .init(.number, "\(maxCounterLabel)")]).text)
        oneLabelDescriptionView.setupViewModel(oneLabelViewModel)
        oneTextFieldView.maxCounter = Int(maxCounterLabel)
        oneTextFieldView.regularExpression = regularExpression
        setAccessibilityInfo(maxCounterLabel: maxCounterLabel)
    }

    override func becomeFirstResponder() -> Bool {
        return oneTextFieldView.becomeFirstResponder()
    }
}

private extension InternalTransferDescriptionView {

    func addDescriptionView() {
        let viewModel = OneInputRegularViewModel(status: .activated, placeholder: localized("sendMoney_hint_description"))
        oneTextFieldView.setupTextField(viewModel)
        addSubview(oneLabelDescriptionView)
        addSubview(oneTextFieldView)
        setConstraints()
    }

    func setConstraints() {
        NSLayoutConstraint.activate([
            oneLabelDescriptionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            oneLabelDescriptionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            oneLabelDescriptionView.topAnchor.constraint(equalTo: topAnchor),
            oneLabelDescriptionView.heightAnchor.constraint(equalToConstant: 24.0),
            oneTextFieldView.leadingAnchor.constraint(equalTo: leadingAnchor),
            oneTextFieldView.trailingAnchor.constraint(equalTo: trailingAnchor),
            oneTextFieldView.topAnchor.constraint(equalTo: oneLabelDescriptionView.bottomAnchor, constant: 10),
            oneTextFieldView.heightAnchor.constraint(equalToConstant: 48.0),
            oneTextFieldView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setAccessibilityInfo(maxCounterLabel: String) {
        setAccessibility { [weak self] in
            guard let self = self else { return }
            self.oneLabelDescriptionView.setAccessibilityLabel(accessibilityLabel: localized("voiceover_insertConcept", [.init(.number, "\(maxCounterLabel)")]).text)
        }
    }

    func bind() {
        oneTextFieldView.publisher
            .case ( ReactiveOneInputRegularViewState.textDidChange )
            .sink { [weak self] text in
                guard let self = self else { return }
                self.oneLabelDescriptionView.setActualCounterLabel(String(text.count))
                self.stateSubject.send(.descriptionDidChange(text))
            }.store(in: &subscriptions)
    }
}

extension InternalTransferDescriptionView: AccessibilityCapable {}

extension InternalTransferDescriptionView: ReactiveInternalTransferDescriptionView {
    public var publisher: AnyPublisher<InternalTransferDescriptionViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
