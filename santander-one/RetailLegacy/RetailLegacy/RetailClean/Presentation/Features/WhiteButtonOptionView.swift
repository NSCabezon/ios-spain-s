import UIKit

protocol WhiteButtonOptionViewDelegate: class {
    func didTapInOpenApp()
}

class WhiteButtonOptionView: UIView {
    
    lazy var button: UIButton = {
        let button = WhiteButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.santanderTextRegular(size: 18.0)
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        addSubview(button)
        return button
    }()
    
    weak var delegate: WhiteButtonOptionViewDelegate?
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.52).isActive = true
        backgroundColor = .clear
    }
    
    func setButtonTitle(_ text: LocalizedStylableText) {
        button.set(localizedStylableText: text, state: .normal)
    }
    
    @objc func didPressButton(_ sender: Any) {
        delegate?.didTapInOpenApp()
    }
}
