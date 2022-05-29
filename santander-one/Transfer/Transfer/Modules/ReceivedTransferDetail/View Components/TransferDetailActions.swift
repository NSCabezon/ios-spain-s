import UI

final class TransferDetailActions: UIView {
    private var actionButtons: [ActionButton] = []

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setViewModels(_ viewModels: [TransferDetailActionViewModel]) {
        viewModels.forEach { (viewModel) in
            let cardAction = self.makeAccountTransactionActionForViewModel(viewModel)
            self.actionButtons.append(cardAction)
        }
        addActionButtonsToStackView()
    }
    
    @objc func performAccountTransactionAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let viewModel = actionButton.getViewModel() as? TransferDetailActionViewModel else { return }
        viewModel.action()
    }
    
    public func addActionButtonsToStackView() {
        self.actionButtons.forEach {
            if actionButtons.count == 1 {
                wrapBetweenClearViews($0)
            } else {
                self.stackView.addArrangedSubview($0)
            }
        }
    }
    
    public func removeSubviews() {
        self.actionButtons.removeAll()
        self.stackView.removeAllArrangedSubviews()
    }
}

// MARK: - Private Methods
private extension TransferDetailActions {
    func setup() {
        self.backgroundColor = UIColor.skyGray
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 16),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            self.stackView.heightAnchor.constraint(equalToConstant: 72),
            self.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: 10)
        ])
    }
    
    func makeAccountTransactionActionForViewModel(_ viewModel: TransferDetailActionViewModel) -> ActionButton {
        let actionButton = ActionButton()
        actionButton.setExtraLabelContent(viewModel.highlightedInfo)
        actionButton.setViewModel(viewModel)
        actionButton.addSelectorAction(target: self, #selector(performAccountTransactionAction))
        actionButton.accessibilityIdentifier = viewModel.accessibilityIdentifier
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.widthAnchor.constraint(lessThanOrEqualToConstant: 168.0).isActive = true
        return actionButton
    }

    func wrapBetweenClearViews(_ actionView: ActionButton) {
        stackView.distribution = .fillProportionally
        let firstView = clearView()
        self.stackView.addArrangedSubview(firstView)
        firstView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        self.stackView.addArrangedSubview(actionView)
        let lastView = clearView()
        self.stackView.addArrangedSubview(lastView)
        lastView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
    }
    
    func clearView() -> UIView {
        let fakeView = UIView()
        fakeView.backgroundColor = .clear
        fakeView.translatesAutoresizingMaskIntoConstraints = false
        return fakeView
    }
}
