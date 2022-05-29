import UIKit

public final class DialogFilterView: UIView {

    @IBOutlet weak var popupFrameView: UIView?
    @IBOutlet weak var closeButton: UIButton?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var buttonUp: WhiteLisboaButton!
    @IBOutlet weak var buttonBottom: RedLisboaButton!
    
    private var responseBlock: ((Bool) -> Void)?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    static public func presentPopup(title: String, description: String, confirmTitle: String, cancelTitle: String, in superview: UIView? = nil, response: @escaping (Bool) -> Void) {
        guard let view = superview ?? UIApplication.shared.windows.first else { return }
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: "DialogFilterView"), bundle: bundle)
        let popupView = nib.instantiate(withOwner: self, options: nil)[0] as? DialogFilterView ?? DialogFilterView()
        
        popupView.titleLabel?.text = title
        popupView.descriptionLabel?.text = description
        popupView.buttonUp?.setTitle(confirmTitle, for: UIControl.State.normal)
        popupView.buttonBottom?.setTitle(cancelTitle, for: UIControl.State.normal)
        popupView.responseBlock = response
        
        popupView.add(to: view)
    }
    // MARK: - privateMethods
    
    private func commonInit() {
        configureFrame()
        configureLabels()
        configureButtons()
    }
    
    private func configureFrame() {
        backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        popupFrameView?.backgroundColor = UIColor.white
        popupFrameView?.layer.cornerRadius = 5.0
    }
    
    private func configureLabels() {
        titleLabel?.textColor = UIColor.black
        titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 22)
        titleLabel?.textAlignment = .center
        descriptionLabel?.configureText(withKey: "", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16), alignment: .center, lineHeightMultiple: 0.85))
        descriptionLabel?.textColor = UIColor.black
    }
    
    private func configureButtons() {
        closeButton?.addTarget(self, action: #selector(closeButtonDidPressed), for: UIControl.Event.touchUpInside)
        buttonUp?.addSelectorAction(target: self, #selector(cancelButtonDidPressed))
        buttonBottom?.addSelectorAction(target: self, #selector(confirmButtonDidPressed))
    }
    
    private func add(to view: UIView) {
        view.addSubview(self)
        
        let centerX = NSLayoutConstraint(item: self as Any, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerY = NSLayoutConstraint(item: self as Any, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let width = NSLayoutConstraint(item: self as Any, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0)
        let height = NSLayoutConstraint(item: self as Any, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0)
        
        view.addConstraints([centerX, centerY, width, height])
        
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        view.layoutSubviews()
        
        showPopup()
    }
    
    private func showPopup() {
        self.alpha = 0.0
        popupFrameView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            self.popupFrameView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            UIView.animate(withDuration: 0.1, animations: {
                strongSelf.popupFrameView?.transform = CGAffineTransform.identity
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
            })
        })
    }
    
    private func hidePopup() {
        self.alpha = 0.0
        self.removeFromSuperview()
    }
    
    @objc private func closeButtonDidPressed() {
        hidePopup()
    }
    
    @objc private func cancelButtonDidPressed() {
        hidePopup()
        responseBlock?(false)
    }
    
    @objc private func confirmButtonDidPressed() {
        hidePopup()
        responseBlock?(true)
    }
}
