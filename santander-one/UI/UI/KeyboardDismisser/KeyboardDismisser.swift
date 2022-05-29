import UIKit
import CoreFoundationLib

public class KeyboardDismisser {
    private weak var viewController: UIViewController?
    private var observer: KeyboardObserver?
    private lazy var wallView: AlwaysLazyProperty<KeyboardWallView> = {
        return AlwaysLazyProperty<KeyboardWallView>(build: { [weak self] in
            let wallView = KeyboardWallView()
            guard let strongSelf = self else { return wallView }
            wallView.addGestureRecognizer(UITapGestureRecognizer(target: strongSelf, action: #selector(KeyboardDismisser.tapViewTouched)))
            return wallView
        })
    }()
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func start() {
        guard observer == nil else {
            return
        }
        observer = KeyboardObserver()
        observer?.delegate = self
    }
    
    public func stop() {
        wallView.property?.removeFromSuperview()
        observer = nil
    }
    
    private func prepareSkippingKeyboard() {
        guard wallView.property?.superview == nil, let view = viewController?.view else {
            return
        }
        viewController?.setPopGestureEnabled(false)
        wallView.property?.add(inView: view)
    }
    
    private func removeSkippingKeyboard() {
        viewController?.setPopGestureEnabled(true)
        wallView.property?.removeFromSuperview()
    }
    
    @objc
    private func tapViewTouched() {
        viewController?.view.endEditing(true)
    }
}

extension KeyboardDismisser: KeyboardObserverDelegate {
    func keyboardEventDidHappen(event: KeyboardEvent) {
        switch event {
        case .willShow:
            prepareSkippingKeyboard()
        case .didHide:
            removeSkippingKeyboard()
        }
    }
}

private class KeyboardWallView: UIView {
    private var coveredView: UIView?
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(inView view: UIView?) {
        guard let view = view else {
            return
        }
        frame = view.frame
        coveredView = view
        DispatchQueue.main.async { [weak self] in
            guard let thisView = self,
                let window = view.window,
                window.subviews.first(where: { $0 is KeyboardWallView }) == nil else {
                    return
            }
            window.addSubview(thisView)
            var builder = NSLayoutConstraint.Builder()
            if #available(iOS 11.0, *) {
                builder = builder
                    .add(thisView.topAnchor.constraint(equalTo: window.topAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.minY))
                    .add(thisView.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor))
                    .add(thisView.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor))
                    .add(thisView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor))
            } else {
                builder = builder
                    .add(thisView.topAnchor.constraint(equalTo: window.topAnchor, constant: thisView.frame.origin.y))
                    .add(thisView.leadingAnchor.constraint(equalTo: window.leadingAnchor))
                    .add(thisView.trailingAnchor.constraint(equalTo: window.trailingAnchor))
                    .add(thisView.bottomAnchor.constraint(equalTo: window.bottomAnchor))
            }
            builder.activate()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let windowConversion = convert(point, to: nil)
        if #available(iOS 11.0, *), windowConversion.y < frame.origin.y {
            return super.hitTest(point, with: event)
        }
        guard
            let conversion = window?.convert(windowConversion, to: coveredView),
            let view = coveredView?.hitTest(conversion, with: event)
            else {
            return nil
        }
        if view.canBecomeFocused || view.canBecomeFirstResponder || UIView.isTextRangeView(view) {
            return view
        } else if view is UIButton {
            return view
        } else if let gestureRecognizers = view.gestureRecognizers, gestureRecognizers.count > 0 {
            return view
        }
        return self
    }
}
