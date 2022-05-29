//
//  SteppedProgressBar.swift
//  UI
//
//  Created by José Carlos Estela Anguita on 15/07/2020.
//

import UIKit
import CoreFoundationLib

public enum ProgressBarType {
    case stepped
    case oneContinuous

    var barHeight: CGFloat {
        switch self {
        case .stepped:
            return 16.0
        case .oneContinuous:
            return 2.0
        }
    }
    
    var segmentMargin: CGFloat {
        switch self {
        case .stepped:
            return 6.0
        case .oneContinuous:
            return 0.0
        }
    }
}

public class SteppedProgressBar: UIView {
    
    // MARK: - Attributes
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -1
        return stackView
    }()
    private var segments: [Segment] {
        return self.stackView.arrangedSubviews.compactMap({ $0 as? Segment })
    }
    private lazy var leftMargin: Margin = {
        return self.margin(filledColor: self.filledColor)
    }()
    private lazy var rightMargin: Margin = {
        return self.margin(filledColor: .clear)
    }()
    private var steps: [Step] {
        return self.stackView.arrangedSubviews.compactMap({ $0 as? Step })
    }
    private var currentStep: Int = 0
    private var unfilledColor: UIColor = .clear
    private var filledColor: UIColor = .clear
    public var currentSteps: Int = 0
    private var progressBarType: ProgressBarType = .stepped
    enum Contants {
        static let margin: CGFloat = 16
        static let stepHeight: CGFloat = 16
        static let defaultSegmentMargin: CGFloat = 6
    }
    
    // MARK: - Public methods

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.heightAnchor.constraint(equalToConstant: progressBarType.barHeight).isActive = true
    }

    public func configure(unfilledColor: UIColor, filledColor: UIColor, progressBarType: ProgressBarType?) {
        self.unfilledColor = unfilledColor
        self.filledColor = filledColor
        guard let progressBarType = progressBarType else { return }
        self.progressBarType = progressBarType
    }
    
    public func setSteps(_ steps: Int, completion: @escaping () -> Void) {
        guard self.currentSteps != steps else { return completion() }
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        UIView.animate(
            withDuration: 0.0,
            animations: { [weak self] in
                guard let self = self else { return }
                self.currentStep = 0
                self.resetViews()
                self.stackView.addArrangedSubview(self.leftMargin)
                self.setupSteps(steps)
                if self.progressBarType == .stepped {
                    self.stackView.addArrangedSubview(self.rightMargin)
                }
                self.currentSteps = steps
            },
            completion: { finished in
                guard finished == true else { return }
                completion()
            }
        )
    }
    
    public func setOnlyOneStep() {
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.currentStep = 0
        self.resetViews()
        let segment = self.segment(filledColor: self.unfilledColor, unfilledColor: self.filledColor)
        self.stackView.addArrangedSubview(segment)
        self.setupSteps(1)
        self.stackView.addArrangedSubview(self.rightMargin)
        self.currentSteps = 1
    }
    
    public func go(to step: Int, animated: Bool) {
        guard self.currentStep != step, step <= self.segments.count else { return }
        self.move(to: step, animated: animated)
    }
}

private extension SteppedProgressBar {

    func setAccessibilityInfo() {
        self.isAccessibilityElement = false
        self.accessibilityIdentifier = "oneProgressBar"
        self.accessibilityLabel = localized("siri_voiceover_progressBar")
    }
    
    func resetViews() {
        self.stackView.removeFromSuperview()
        self.leftMargin = self.margin(filledColor: self.filledColor)
        self.rightMargin = self.margin(filledColor: .clear)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        self.stackView = stackView
        self.addSubview(self.stackView)
        self.stackView.fullFit()
    }
    
    func move(to step: Int, animated: Bool) {
        if self.currentStep > step {
            self.moveBackward(to: step, animated: animated) {
                self.currentStep = step
            }
        } else {
            self.moveForward(to: step, animated: animated) {
                self.currentStep = step
            }
        }
    }
    
    func moveBackward(to step: Int, animated: Bool, completion: @escaping () -> Void) {
        self.moveBackward(to: step, current: self.currentStep, animated: animated) {
            guard step == 0 else { return completion() }
            self.leftMargin.fill(animated: animated, completion: completion)
        }
    }
    
    func moveForward(to step: Int, animated: Bool, completion: @escaping () -> Void) {
        if self.progressBarType == .stepped {
            self.leftMargin.unfill(animated: animated) {
                self.moveForward(to: step, current: self.currentStep, animated: animated, completion: completion)
            }
        } else {
            self.leftMargin.fillContinuous(animated: animated) {
                self.moveForward(to: step, current: self.currentStep, animated: animated, completion: completion)
            }
        }
    }
    
    func moveForward(to step: Int, current: Int, animated: Bool, completion: @escaping () -> Void) {
        guard step != current else { return completion() }
        if self.progressBarType == .stepped {
            self.steps[current].setState(.done)
        }
        self.segments[current].moveForward(animated: animated) {
            if self.progressBarType == .stepped {
                self.steps[current + 1].setState(.selected)
            }
            self.moveForward(to: step, current: current + 1, animated: animated, completion: completion)
        }
    }
    
    func moveBackward(to step: Int, current: Int, animated: Bool, completion: @escaping () -> Void) {
        guard step != current else { return completion() }
        if self.progressBarType == .stepped {
            self.steps[current].setState(.unselected)
        }
        guard current > 0 else { return completion() }
        self.segments[current - 1].moveBackward(animated: animated) {
            if self.progressBarType == .stepped {
                self.steps[current - 1].setState(.selected)
            }
            self.moveBackward(to: step, current: current - 1, animated: animated, completion: completion)
        }
    }
    
    func margin(filledColor: UIColor) -> Margin {
        let view = Margin(color: filledColor, progressBarType: self.progressBarType)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Contants.margin).isActive = true
        return view
    }
    
    func segment(filledColor: UIColor, unfilledColor: UIColor) -> Segment {
        let view = Segment(filledColor: filledColor, unfilledColor: unfilledColor, progressBarType: self.progressBarType)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setupSteps(_ steps: Int, current: Int = 1, lastSegment: Segment? = nil) {
        if self.progressBarType == .stepped {
            self.stackView.addArrangedSubview(self.step(current))
        }
        let isSegmentNeeded = steps != current
        guard isSegmentNeeded else { return }
        let segment = self.segment(filledColor: self.filledColor, unfilledColor: self.unfilledColor)
        self.stackView.addArrangedSubview(segment)
        guard let previousSegmentWidthAnchor = lastSegment?.widthAnchor else {
            return self.setupSteps(steps, current: current + 1, lastSegment: segment)
        }
        segment.widthAnchor.constraint(equalTo: previousSegmentWidthAnchor).isActive = true
        return self.setupSteps(steps, current: current + 1, lastSegment: segment)
    }
    
    func step(_ index: Int) -> Step {
        let config = StepConfiguration(
            index: index,
            unfilledColor: self.unfilledColor,
            filledColor: self.filledColor
        )
        let view = Step(configuration: config)
        if index < self.currentStep {
            view.setState(.done)
        } else if self.currentStep == index - 1 {
            view.setState(.selected)
        } else {
            view.setState(.unselected)
        }
        return view
    }
}

extension SteppedProgressBar: AccessibilityCapable {}
