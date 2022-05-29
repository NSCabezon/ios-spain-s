import UIKit
import CoreFoundationLib

public struct FaqsViewData {
    public let items: [FaqsItemViewModel]
    
    public init(items: [FaqsItemViewModel]) {
        self.items = items
    }
    
    @discardableResult
    public func show(in viewController: UIViewController) -> FaqsViewController {
        let faqsViewController = FaqsViewController(nibName: "FaqsViewController", bundle: .module)
        if let delegate = viewController as? FaqsViewControllerDelegate {
            faqsViewController.delegate = delegate
        }
        faqsViewController.modalPresentationStyle = .overCurrentContext
        viewController.present(faqsViewController, animated: false, completion: {
            faqsViewController.configure(self)
        })
        return faqsViewController
    }
}

public protocol FaqsViewControllerDelegate: AnyObject {
    func didExpandAnswer(question: String)
    func didTapAnswerLink(question: String, url: URL)
}

public class FaqsViewController: UIViewController {
    
    weak var delegate: FaqsViewControllerDelegate?
    @IBOutlet private var stackView: Stackview!
    @IBOutlet private var transparentView: UIView!
    @IBOutlet private var bottomTransparentView: UIView!
    @IBOutlet private var sliderView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var containedView: UIView!
    @IBOutlet private var titleView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var crossImage: UIImageView!
    @IBOutlet private var noHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var scrollHeightConstraint: NSLayoutConstraint!
    private var firstTime: Bool = true
    private var isMaxView: Bool = false
    @IBOutlet private var closeButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    func configure(_ data: FaqsViewData) {
        self.noHeightConstraint.constant = self.view.frame.size.height
        self.view.layoutSubviews()
        self.titleView.roundCorners(corners: [.topLeft, .topRight], radius: 4)
        self.addGradientToView(view: self.titleView)
        for index in 0..<data.items.count {
            let item = data.items[index]
            let view = FaqItemView()
            view.delegate = self
            let isSeparatorVisible = data.items.count > 1 && index < data.items.count - 1
            view.configure(item, separator: isSeparatorVisible)
            self.stackView.addArrangedSubview(view)
        }
        self.stackView.delegate = self
    }
}

// MARK: - Private Methods

private extension FaqsViewController {
    @IBAction func closeView() {
        self.stackView.delegate = nil
        self.scrollHeightConstraint.constant = 0
        self.noHeightConstraint.constant = self.view.frame.size.height
        UIView.animate(withDuration: 0.5, animations: {
            self.transparentView.backgroundColor = UIColor.clear
            self.view.layoutSubviews()
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: nil)
        })
    }
    
    @IBAction func swipeUp() {
        self.openView()
    }
    
    @IBAction func swipeDown() {
       self.closeView()
    }
    
    func setupView() {
        self.noHeightConstraint.constant = self.view.frame.size.height
        self.view.layoutSubviews()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        swipeGesture.direction = .up
        self.containerView.addGestureRecognizer(swipeGesture)
        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeGestureDown.direction = .down
        self.containerView.addGestureRecognizer(swipeGestureDown)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.transparentView.backgroundColor = .clear
        self.bottomTransparentView.backgroundColor = UIColor.white
        self.crossImage.image = Assets.image(named: "icnCloseGray")
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.cornerRadius = 6
        self.containerView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 6)
        }
        self.containerView.addShadow(location: .top, opacity: 0.4, height: 1)
        self.containerView.layer.shadowRadius = 6
        self.containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.sliderView.backgroundColor = UIColor.lightSanGray
        self.sliderView.layer.cornerRadius = 2
        self.containedView.backgroundColor = UIColor.white
        self.containedView.layer.cornerRadius = 4
        self.containedView.layer.borderWidth = 1
        self.containedView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.containedView.layer.masksToBounds = true
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 20)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.configureText(withLocalizedString: localized("helpCenter_title_faqs"))
        
        setAccesibility()
    }
    
    func openView() {
        if self.noHeightConstraint.constant != 0 && !self.isMaxView {
            self.noHeightConstraint.constant = self.view.layoutMargins.top
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutSubviews()
            })
        }
    }
    
    func addGradientToView(view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.lightNavy.cgColor, UIColor.darkTorquoise.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: UIGestureRecognizerDelegate

extension FaqsViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}

// MARK: - FaqItemViewDelegate

extension FaqsViewController: FaqItemViewDelegate {
    func didSelectFaqItemView() {
        self.openView()
    }
    
    func didExpandAnswer(question: String) {
        delegate?.didExpandAnswer(question: question)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        delegate?.didTapAnswerLink(question: question, url: url)
    }
}

// MARK: - StackviewDelegate

extension FaqsViewController: StackviewDelegate {
    public func didChangeBounds(for stackview: UIStackView) {
        let maxSize = self.view.frame.size.height - 106 - self.view.layoutMargins.bottom - self.view.layoutMargins.top
        let targetSize = min(maxSize, self.stackView.frame.size.height)
        self.scrollHeightConstraint.constant = targetSize
        if self.firstTime {
            self.isMaxView = targetSize == maxSize
            self.firstTime = false
            self.stackView.delegate = nil
            self.noHeightConstraint.constant = self.view.frame.size.height - 106 - targetSize - self.view.layoutMargins.bottom
            UIView.animate(withDuration: 0.5, animations: {
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                self.view.layoutSubviews()
            }, completion: { [weak self] _ in
                self?.stackView.delegate = self
            })
        } else {
            self.view.layoutSubviews()
        }
    }
}

private extension FaqsViewController {
    func setAccesibility() {
        self.closeButton.accessibilityLabel = localized("siri_voiceover_close")
    }
}
