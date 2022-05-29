import UIKit
import UI
import CoreFoundationLib

public protocol OperativeConfirmationPresenterProtocol: OperativeStepPresenterProtocol {
    func didSelectContinue()
}

public protocol OperativeConfirmationViewProtocol: OperativeView {
    func add(_ confirmationItems: [ConfirmationItemViewModel])
    func add(_ confirmationItem: ConfirmationItemViewModel)
    func add(_ totalViewItem: ConfirmationTotalOperationItemViewModel)
    func add(_ containerItem: ConfirmationContainerViewModel)
    func add(_ containerView: UIView)
    func add(_ containerViews: [UIView])
    func setContinueTitle(_ text: String)
}

open class OperativeConfirmationViewController: UIViewController {
    
    @IBOutlet private weak var stackViewContainerView: UIView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var stackFooterView: UIStackView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    private let presenter: OperativeConfirmationPresenterProtocol
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public init(presenter: OperativeConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "OperativeConfirmation", bundle: .module)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    open func addConfirmationItemView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    @objc private func continueButtonSelected() {
        self.presenter.didSelectContinue()
    }

    open func addFooterView(_ view: UIView) {
        self.continueButton.isHidden = true
        self.stackFooterView.addArrangedSubview(view)
    }
}

private extension OperativeConfirmationViewController {
    
    func setupView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.drawBorder(cornerRadius: 0, color: .mediumSkyGray)
        view.backgroundColor = .white
        view.addSubview(self.stackView)
        self.stackViewContainerView.addSubview(self.scrollView)
        self.scrollView.addSubview(view)
        view.fullFit(topMargin: 26, bottomMargin: 26)
        self.setupLayoutConstraints()
        self.view.backgroundColor = .skyGray
        self.separator.backgroundColor = .mediumSkyGray
        self.continueButton.addSelectorAction(target: self, #selector(continueButtonSelected))
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnSend.rawValue
    }
    
    func setupLayoutConstraints() {
        self.stackView.widthAnchor.constraint(equalTo: self.stackViewContainerView.widthAnchor).isActive = true
        self.scrollView.fullFit()
        self.stackView.fullFit()
    }
}

extension OperativeConfirmationViewController: OperativeConfirmationViewProtocol {
    
    public var operativePresenter: OperativeStepPresenterProtocol {
        self.presenter
    }
    
    public func setContinueTitle(_ text: String) {
        self.continueButton.setTitle(text, for: .normal)
    }
    
    public func add(_ confirmationItem: ConfirmationItemViewModel) {
        let confirmationItemView = ConfirmationItemView(frame: .zero)
        confirmationItemView.translatesAutoresizingMaskIntoConstraints = false
        confirmationItemView.setup(with: confirmationItem)
        self.addConfirmationItemView(confirmationItemView)
    }
    
    public func add(_ confirmationItems: [ConfirmationItemViewModel]) {
        confirmationItems.forEach(add)
    }
    
    public func add(_ totalViewItem: ConfirmationTotalOperationItemViewModel) {
        let total = ConfirmationTotalOperationItemView(frame: .zero)
        total.translatesAutoresizingMaskIntoConstraints = false
        total.setup(with: totalViewItem)
        self.addConfirmationItemView(total)
    }
    
    public func add(_ containerItem: ConfirmationContainerViewModel) {
        let containerItemView = ConfirmationContainerView(frame: .zero)
        containerItemView.translatesAutoresizingMaskIntoConstraints = false
        containerItemView.setup(containerItem)
        self.addConfirmationItemView(containerItemView)
    }
    
    public func add(_ containerView: UIView) {
        let containerItemView = containerView
        containerItemView.translatesAutoresizingMaskIntoConstraints = false
        self.addConfirmationItemView(containerItemView)
    }
    
    public func add(_ containerViews: [UIView]) {
        containerViews.forEach(add)
    }
}
