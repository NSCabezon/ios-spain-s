//
//  InternalTransferDateView.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 24/2/22.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import OpenCombine

enum InternalTransferDateViewType {
    case today
    case allowDateSelection(selectionDateViewModel: SelectionDateOneFilterViewModel, inputDateViewModel: OneInputDateViewModel)
}

struct InternalTransferDateViewConfiguration {
    let type: InternalTransferDateViewType

    init(type: InternalTransferDateViewType) {
        self.type = type
    }
}

public protocol ReactiveInternalTransferDateView {
    var publisher: AnyPublisher<ReactiveInternalTransferDateViewState, Never> { get }
}

public enum ReactiveInternalTransferDateViewState: State {
    case didSelectIssueDate(_ date: Date)
    case didSelecteOneFilterSegment(_ type: SendMoneyDateTypeViewModel)
}

final class InternalTransferDateView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    private let stateSubject = PassthroughSubject<ReactiveInternalTransferDateViewState, Never>()
    private lazy var selectionDateOneFilterView: SelectionDateOneFilterView = {
        let view = SelectionDateOneFilterView()
        view.delegate = self
        return view
    }()
    private lazy var issueDateView: IssueDateOneSelectView = {
        let view = IssueDateOneSelectView()
        view.delegate = self
        return view
    }()
    private lazy var todayView = InternalTransferLabelsView(title: localized("sendMoney_label_dateSending"),
                                                            description: localized("sendMoney_label_today"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviews()
    }

    func configureView(_ configuration: InternalTransferDateViewConfiguration) {
        switch configuration.type {
        case .today:
            addTodayView()
            didSelectIssueDate(Date())
        case .allowDateSelection(selectionDateViewModel: let selectionDateViewModel, inputDateViewModel: let inputDateViewModel):
            addSelectionDateOneFilterView(selectionDateViewModel)
            addIssueDateView(inputDateViewModel)
            didSelecteOneFilterSegment(selectionDateViewModel.selectedIndex)
        }
    }
}

private extension InternalTransferDateView {
    func addSubviews() {
        addSubview(stackView)
        stackView.fullFit()
    }

    func addTodayView() {
        stackView.addArrangedSubview(todayView)
    }

    func addSelectionDateOneFilterView(_ viewModel: SelectionDateOneFilterViewModel) {
        selectionDateOneFilterView.setViewModel(viewModel)
        stackView.addArrangedSubview(selectionDateOneFilterView)
    }

    func addIssueDateView(_ viewModel: OneInputDateViewModel) {
        issueDateView.setViewModel(viewModel)
        issueDateView.isHidden = true
        stackView.addArrangedSubview(issueDateView)
    }

    func didSelectNow() {
        issueDateView.isHidden = true
    }

    func didSelectDay() {
        issueDateView.isHidden = false
        issueDateView.setVoiceOverFocus()
    }

    func didSelectSegment(_ sendMoneyDateType: SendMoneyDateTypeViewModel) {
        switch sendMoneyDateType {
        case .now:
            didSelectNow()
        case .day:
            didSelectDay()
        case .periodic:
            assertionFailure("Not available option")
        }
    }
}

extension InternalTransferDateView: SelectionDateOneFilterDelegate {
    func didSelecteOneFilterSegment(_ index: Int) {
        var sendMoneyDateType: SendMoneyDateTypeViewModel = .now
        switch(index) {
        case 0:
            sendMoneyDateType = .now
        case 1:
            sendMoneyDateType = .day
        default: break
        }
        didSelectSegment(sendMoneyDateType)
        stateSubject.send(.didSelecteOneFilterSegment(sendMoneyDateType))
    }
}

extension InternalTransferDateView: IssueDateOneSelectDelegate {
    func didSelectIssueDate(_ date: Date) {
        stateSubject.send(.didSelectIssueDate(date))
    }
}

extension InternalTransferDateView: ReactiveInternalTransferDateView {
    public var publisher: AnyPublisher<ReactiveInternalTransferDateViewState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}
