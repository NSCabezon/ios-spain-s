//
//  Toast.swift
//  UI
//
//  Created by alvola on 20/11/2019.
//

import UIKit

public class Toast {
    public static var timeLapse: TimeInterval = 1.0 {
        didSet {
            toastController?.timeLapse = timeLapse
        }
    }
    public static var font: UIFont = .systemFont(ofSize: 16.0) {
        didSet {
            toastController?.font = font
        }
    }
    public static var textColor: UIColor = .black {
        didSet {
            toastController?.textColor = textColor
        }
    }
    public static var toastAlpha: CGFloat = 1.0 {
        didSet {
            toastController?.toastAlpha = toastAlpha
        }
    }
    public static var toastColor: UIColor = .white {
        didSet {
            toastController?.toastColor = toastColor
        }
    }
    
    private static var toastController: ToastController?
    
    public class func enable() {
        toastController = ToastController()
        toastController?.timeLapse = timeLapse
        toastController?.font = font
        toastController?.textColor = textColor
        toastController?.toastColor = toastColor
        toastController?.toastAlpha = toastAlpha
        toastController?.prepare()
    }
    
    class func configureToast() {
        Toast.timeLapse = 3.0
        Toast.font = UIFont(name: "Lato-Bold", size: 14.0) ?? UIFont.santander(family: .text, size: 14.0)
        Toast.textColor = .white
        Toast.toastColor = .lisboaGray
        Toast.toastAlpha = 0.9
        Toast.enable()
    }
    
    public class func show(_ message: String) {
        toastController?.add(toast: ToastViewModel(message: message))
    }
}

class ToastController {
    var timeLapse: TimeInterval!
    var font: UIFont!
    var textColor: UIColor!
    var toastColor: UIColor!
    var toastAlpha: CGFloat!
    
    private lazy var window: ToastsWindow = {
        return ToastsWindow()
    }()
    
    private var toasts: [ToastView]
    
    init() {
        toasts = []
    }
    
    func prepare() {
        window.isHidden = true
    }
    
    func add(toast: ToastViewModel) {
        let toastView = createToast(viewModel: toast)
        
        window.add(toastView: toastView)
        
        toasts += [toastView]
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(timeLapse * 1000))) {
            self.remove(toast: toast)
        }
    }
    
    private func createToast(viewModel: ToastViewModel) -> ToastView {
        let toastView = ToastView()
        toastView.messageLabel.font = font
        toastView.messageLabel.textColor = textColor
        toastView.backgroundColor = toastColor
        toastView.alpha = toastAlpha
        toastView.viewModel = viewModel
        
        return toastView
    }
    
    private func remove(toast: ToastViewModel) {
        toasts = toasts.filter { view in
            if toast === view.viewModel {
                self.window.remove(toastView: view)
            }
            return toast !== view.viewModel
        }
    }
}

class ToastViewModel {
    var message: String
    
    init(message: String) {
        self.message = message
    }
}

private class ToastsWindow: UIWindow {
    weak var filterView: UIView! {
        didSet {
            filterView.backgroundColor = .darkGray
            filterView.alpha = 0.3
        }
    }
    weak var toastsContainer: UIView! {
        didSet {
            toastsContainer.backgroundColor = .clear
        }
    }
    
    weak var toastsStack: UIStackView! {
        didSet {
            toastsStack.distribution = .fill
            toastsStack.alignment = .fill
            toastsStack.axis = .vertical
            toastsStack.spacing = 10.0
        }
    }
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        windowLevel = UIWindow.Level.alert
        backgroundColor = .clear
        
        build()
    }
    
    private func build() {
        let filter = UIView(frame: bounds)
        filter.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(filter)
        filterView = filter
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.embedInto(container: self)
    
        toastsContainer = container
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let builder = NSLayoutConstraint.Builder()
            .add(stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 40.0))
            .add(stack.centerXAnchor.constraint(equalTo: container.centerXAnchor))
            .add(stack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.75))
            .add(stack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor))
        
        container.addSubview(stack)
        toastsStack = stack
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDetected(tapRecognizer:)))
        container.addGestureRecognizer(tapGesture)
        
        builder.activate()
    }
    
    @objc
    private func tapDetected(tapRecognizer: UITapGestureRecognizer) {
        for toast in toastsStack.arrangedSubviews {
            if let toast = toast as? ToastView {
                remove(toastView: toast)
            }
        }
    }
    
    func add(toastView: ToastView) {
        
        func onceToastDidDraw(onDraw: @escaping () -> Void) {
            DispatchQueue.main.async {
                onDraw()
            }
        }
        
        if isHidden {
            show {
                self.add(toastView: toastView)
            }
            return
        }
        
        let alpha = toastView.alpha
        toastView.alpha = 0.0
        toastsStack.insertArrangedSubview(toastView, at: 0)
        
        onceToastDidDraw {
            let deltaY = -toastView.superview!.frame.origin.y - toastView.frame.origin.y - toastView.frame.height - 10.0
            toastView.transform = CGAffineTransform(translationX: 0.0, y: deltaY)
            UIView.animate(withDuration: 0.5, animations: {
                toastView.alpha = alpha
                toastView.transform = .identity
            })
        }
    }
    
    func remove(toastView: ToastView) {
        guard toastView.superview != nil else {
            return
        }
        UIView.animate(withDuration: 0.5, animations: {
            let deltaY = -toastView.superview!.frame.origin.y - toastView.frame.origin.y - toastView.frame.height - 10.0
            toastView.transform = CGAffineTransform(translationX: 0.0, y: deltaY)
            toastView.alpha = 0.0
        }, completion: { _ in
            self.toastsStack.removeArrangedSubview(toastView)
            if self.toastsStack.arrangedSubviews.isEmpty {
                self.dismiss()
            }
        })
    }
    
    private func show(completion: @escaping () -> Void = {}) {
        alpha = 0.0
        makeKeyAndVisible()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1.0
            completion()
        })
    }
    
    private func dismiss(completion: @escaping () -> Void = {}) {
        if !isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.isHidden = true
                completion()
            })
        }
    }
}

private class ToastView: UIView {
    var viewModel: ToastViewModel! {
        didSet {
            messageLabel.text = viewModel.message
        }
    }
    
    weak var messageLabel: UILabel!
    
    init() {
        super.init(frame: CGRect())
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10.0
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init not supported")
    }
    
    private func build() {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        messageLabel.embedInto(container: self, padding: 10.0)
        
        self.messageLabel = messageLabel
    }
}

extension NSLayoutConstraint {
    class Builder {
        private var constraints: [NSLayoutConstraint]
        
        init() {
            constraints = []
        }
        
        func add(_ constraint: NSLayoutConstraint) -> Self {
            constraints += [constraint]
            return self
        }
        
        func activate() {
            NSLayoutConstraint.activate(constraints)
            constraints = []
        }
        
        static func += (builder: Builder, constraint: NSLayoutConstraint) {
            _ = builder.add(constraint)
        }
    }
}

extension UIView {
    func embedInto(container: UIView, insets: UIEdgeInsets = UIEdgeInsets()) {
        let builder = NSLayoutConstraint.Builder()
            .add(topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top))
            .add(leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left))
            .add(trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: insets.right))
            .add(bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: insets.bottom))
        
        container.addSubview(self)
        
        builder.activate()
    }
    
    func embedInto(container: UIView, padding: CGFloat) {
        embedInto(container: container, insets: paddingToInsets(padding: padding))
    }
    
    private func paddingToInsets(padding: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding)
    }
}
