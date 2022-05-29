import UIKit
import CoreFoundationLib
import UIOneComponents

protocol EnvironmentsSelectorPresenterContract: Presenter {
    func environmentsSelected(selectors: [EnvironmentSelectorViewModel])
    func environmentsSelectionCancelled()
    func didSelectFeatureFlags()
}

private enum SelectionStatus {
    case saved
    case cancelled
}

class EnvironmentsSelectorViewController: BaseViewController<EnvironmentsSelectorPresenterContract> {
    override class var storyboardName: String {
        return "EnvironmentsSelector"

    }
    override class var viewControllerIdentifier: String {
        return "environmentsSelectorController"
    }

    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var toolBar: UIToolbar!
    @IBOutlet private weak var environmentsContainer: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var environmentsStack: UIStackView!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var acceptButton: RedButton!
    @IBOutlet private weak var closeButton: UIBarButtonItem!
    @IBOutlet private var containerTopLimitation: NSLayoutConstraint!
    @IBOutlet private weak var fakeScrollHeight: NSLayoutConstraint!
    @IBOutlet private weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet private weak var containerCenterVertical: NSLayoutConstraint!

    private var selectors: [EnvironmentSelectorViewModel] = []
    private var pickers: [PickerController<EnvironmentViewModel>] = []
    private var status = SelectionStatus.cancelled
    private lazy var featureFlagsButton: WhiteButton = {
        let button = WhiteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.set(localizedStylableText: localized(key: "Feature Flags"), state: .normal)
        button.accessibilityIdentifier = "button_feature_flags"
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.onTouchAction = { [weak self] _ in
            self?.featureFlagSelected()
        }
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        containerTopLimitation.isActive = false
        fakeScrollHeight.constant = 0.0
        containerCenterVertical.constant = view.frame.height / 4.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollHeight.constant = environmentsStack.frame.height
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        containerTopLimitation.isActive = true
        containerCenterVertical.constant = 0.0
        fakeScrollHeight.isActive = false
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func fillSelector(selector: EnvironmentSelectorViewModel) {
        selectors.append(selector)
        add(selector: selector)
        addFeatureFlagsButton()
    }

    func disableBsanEnvironmentSelector() {
        if let subview = environmentsStack.arrangedSubviews.first as? EnvironmentSelectorView {
            subview.disable()
        }
    }

    func getSelectors() -> [EnvironmentSelectorViewModel] {
        return selectors
    }

    func select(on selector: EnvironmentSelectorViewModel, valueWithName value: String) {
        guard let selectorIndex = (selectors.firstIndex {
            $0.title.text == selector.title.text
        }) else {
            return
        }
        guard let selected = (selector.environments.first {
            $0.title == value
        }) else {
            return
        }
        selectors[selectorIndex].selected = selected
        let picker = pickers[selectorIndex]
        picker.selectedValue = selected
    }

    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        status = .cancelled
        dismiss(animated: true, completion: nil)
    }

    override func prepareView() {
        toolBar.tintColor = .uiWhite
        toolBar.clearBackground()
        gradientView.backgroundColor = .sanGreyDark
        gradientView.alpha = 0.5
        environmentsContainer.clipsToBounds = true
        environmentsContainer.applyDefaultCornerRadius()
        bottomSeparator.backgroundColor = .uiWhite
        acceptButton.set(localizedStylableText: localized(key: "generic_button_accept"), state: .normal)
        acceptButton.onTouchAction = { button in
            self.status = .saved
            self.dismiss(animated: true, completion: nil)
        }
        self.acceptButton.accessibilityIdentifier = AccessibilityEnvironmentSelector.btnAccept.rawValue
        self.closeButton.accessibilityIdentifier = AccessibilityEnvironmentSelector.btnClose.rawValue
    }

    private func add(selector: EnvironmentSelectorViewModel) {
        let selectorView = EnvironmentSelectorView.create()
        selectorView.titleLabel.set(localizedStylableText: selector.title)

        environmentsStack.addArrangedSubview(selectorView)
        for subview in environmentsStack.arrangedSubviews {
            if let subview = subview as? EnvironmentSelectorView {
                subview.separator.isHidden = false
            }
        }

        if let lastSubview = environmentsStack.arrangedSubviews.last as? EnvironmentSelectorView {
            lastSubview.separator.isHidden = true
        }

        let picker = PickerController(elements: selector.environments, labelPrefix: "", relatedView: selectorView.selectorControl, selectionViewType: .accessoryView)
        picker.onSelection = { selected in
            self.update(selector: selector, with: selected)
        }
        picker.selectedValue = selector.selected

        pickers += [picker]
    }

    private func update(selector: EnvironmentSelectorViewModel, with selected: EnvironmentViewModel) {
        guard let index = selectors.firstIndex(where: { $0.title.text == selector.title.text }) else {
            return
        }
        selectors[index].selected = selected
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()
            self.presenter = nil
        }
        switch status {
        case .saved:
            presenter.environmentsSelected(selectors: selectors)
        case .cancelled:
            presenter.environmentsSelectionCancelled()
        }
    }
}

private extension EnvironmentsSelectorViewController {
    
    func featureFlagSelected() {
        presenter.didSelectFeatureFlags()
    }
    
    func addFeatureFlagsButton() {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(featureFlagsButton, topMargin: .oneSizeSpacing16, bottomMargin: .oneSizeSpacing16, leftMargin: .oneSizeSpacing16, rightMargin: .oneSizeSpacing16)
        environmentsStack.addArrangedSubview(view)
    }
}
