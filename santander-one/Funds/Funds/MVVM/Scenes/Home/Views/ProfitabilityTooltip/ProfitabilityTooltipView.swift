//
//  ProfitabilityTooltip.swift
//  Funds
//

import UI
import CoreFoundationLib

enum ProfitabilityTooltipConstants {
    static let tooltipViewFullHeightConstant: CGFloat = 246
    static let tooltipViewRadius: CGFloat = 12
    static let handlerViewRadius: CGFloat = 3
    static let dismissableConstant: CGFloat = 120
    static let animationDuration: TimeInterval = 0.4
}

enum ProfitabilityTooltipIdentifiers {
    static let nibName: String = "ProfitabilityTooltipView"
    static let iconClose: String = "icnClose"
    static let titleLabel: String = "funds_title_profitability"
    static let explanationLabel: String = "funds_text_profitability"
}

final class ProfitabilityTooltipView: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var tooltipView: UIView!
    @IBOutlet private weak var tooltipViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var handlerView: UIView!
    @IBOutlet private weak var closeView: UIView!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var explanationLabel: UILabel!

    private var currentTooltipViewHeight: CGFloat = ProfitabilityTooltipConstants.tooltipViewFullHeightConstant
    private var externalDependencies: FundsHomeExternalDependenciesResolver

    init(_ externalDependencies: FundsHomeExternalDependenciesResolver) {
        self.externalDependencies = externalDependencies
        super.init(nibName: ProfitabilityTooltipIdentifiers.nibName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        trackScreen()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showProfitabilityTooltipView()
    }

    @IBAction func closeButtonDidPressed(_ sender: UIButton) {
        trackEvent(.close)
        self.closeTooltipView()
    }
}

private extension ProfitabilityTooltipView {
    func setupView() {
        self.backgroundView.alpha = 0
        self.tooltipViewHeightConstraint.constant = 0
        self.tooltipView.layer.cornerRadius = ProfitabilityTooltipConstants.tooltipViewRadius
        self.handlerView.layer.cornerRadius = ProfitabilityTooltipConstants.handlerViewRadius
        self.closeImageView.image = UIImage(named: ProfitabilityTooltipIdentifiers.iconClose, in: .module, compatibleWith: nil)
        self.titleLabel.text = localized(ProfitabilityTooltipIdentifiers.titleLabel)
        self.explanationLabel.text = localized(ProfitabilityTooltipIdentifiers.explanationLabel)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeTooltipView))
        self.backgroundView.addGestureRecognizer(tapGestureRecognizer)
        self.setupPanGesture()
        self.setAccessibility {
            self.closeButton.accessibilityLabel = localized("voiceover_closeHelp")
            self.titleLabel.isAccessibilityElement = false
        }
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        self.tooltipView.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let newHeight = self.currentTooltipViewHeight - translation.y
        switch gesture.state {
        case .changed:
            if newHeight < ProfitabilityTooltipConstants.tooltipViewFullHeightConstant {
                self.tooltipViewHeightConstraint.constant = newHeight
                self.view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < ProfitabilityTooltipConstants.dismissableConstant {
                self.closeTooltipView()
            }
            else if newHeight < ProfitabilityTooltipConstants.tooltipViewFullHeightConstant {
                self.animateTooltipViewHeight(ProfitabilityTooltipConstants.tooltipViewFullHeightConstant)
            }
        default:
            break
        }
    }

    func animateTooltipViewHeight(_ height: CGFloat) {
        UIView.animate(withDuration: ProfitabilityTooltipConstants.animationDuration) {
            self.tooltipViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }
        self.currentTooltipViewHeight = height
    }

    func showProfitabilityTooltipView() {
        UIView.animate(withDuration: ProfitabilityTooltipConstants.animationDuration) {
            self.backgroundView.alpha = 1
            self.tooltipViewHeightConstraint.constant = ProfitabilityTooltipConstants.tooltipViewFullHeightConstant
            self.view.layoutIfNeeded()
        }
    }

    @objc func closeTooltipView() {
        UIView.animate(withDuration: ProfitabilityTooltipConstants.animationDuration) {
            self.backgroundView.alpha = 0
            self.tooltipViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

extension ProfitabilityTooltipView: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        externalDependencies.resolve()
    }

    var trackerPage: FundProfitabilityPage {
        FundProfitabilityPage()
    }
}

extension ProfitabilityTooltipView: AccessibilityCapable {}
