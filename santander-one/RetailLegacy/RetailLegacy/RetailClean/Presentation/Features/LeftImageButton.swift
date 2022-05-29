import UIKit

class LeftImageButton: UIControl, ViewCreatable {
    
    var action: (() -> Void)?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var actionTitle: String? {
        get {
            return actionLabel.text
        }
        set {
            actionLabel.text = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    private func setupViews() {
        actionLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoBold(size: 16), textAlignment: .center))
        heightAnchor.constraint(equalToConstant: 67).isActive = true
        addTarget(self, action: #selector(performAction), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 0.4
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 1
        }
        sendActions(for: .touchUpInside)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 1
        }
    }
    
    @objc func performAction() {
        action?()
    }
}
