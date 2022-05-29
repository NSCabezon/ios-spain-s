import UI
import CoreFoundationLib

final class ClassicPGOptionBar: DesignableView {
    
    @IBOutlet weak var topContainerView: UIView?
    
    lazy var topStackView: ActionButtonsStackView<GpOperativesViewModel> = {
        let stackView = ActionButtonsStackView<GpOperativesViewModel>()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    override func commonInit() {
        super.commonInit()
        
        configureView()
        configureTopStackView()
    }
    
    func setOptions(_ options: [GpOperativesViewModel]?) {
        guard let options = options else { return }
        topStackView.subviews.forEach { $0.removeFromSuperview() }
        topStackView.addActions(options)
    }

    private func configureView() {
        topContainerView?.backgroundColor = .clear
    }

    private func configureTopStackView() {
        
        topContainerView?.addSubview(topStackView)
        topContainerView?.topAnchor.constraint(equalTo: topStackView.topAnchor, constant: -6).isActive = true
        topContainerView?.leftAnchor.constraint(equalTo: topStackView.leftAnchor, constant: -8).isActive = true
        topContainerView?.rightAnchor.constraint(equalTo: topStackView.rightAnchor, constant: 8).isActive = true
        topContainerView?.bottomAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 8).isActive = true
    }
}
