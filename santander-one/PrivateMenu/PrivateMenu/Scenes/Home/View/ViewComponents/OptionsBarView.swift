import UIKit
import CoreFoundationLib
import OpenCombine
import UI
import CoreDomain

final class OptionsBarView: UIView {
    let optionsSubject = CurrentValueSubject<[PrivateMenuFooterOption], Never>([])
    let didSelectOptionSubject = PassthroughSubject<(FooterOptionType), Never>()
    let personalManagerBadgeSubject = PassthroughSubject<Bool, Never>()
    let personalManagerImageSubject = PassthroughSubject<UIImage, Never>()
    private var anySubscriptions = Set<AnyCancellable>()

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.spacing = 2
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        containerStackView.embedInto(container: self)
        bind()
    }
    
    func setOptions(_ options: [PrivateMenuFooterOption]) {
        for view in containerStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        var previousButton: PressFXView?
        for option in options {
            let button = PressFXView()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setOptionValueSubject.send(option)
            button.tapSubject
                .sink { [unowned self] option in
                    self.didSelectOptionSubject.send(option)
                }
                .store(in: &anySubscriptions)
            button.isAccessibilityElement = true
            containerStackView.addArrangedSubview(button)
            if previousButton != nil {
                previousButton?.contentTopAnchor.constraint(equalTo: button.contentTopAnchor).isActive = true
            } else {
                previousButton = button
            }
        }
    }
    
    func setNotificationBadgeVisible(_ visible: Bool) {
        containerStackView.arrangedSubviews.forEach {
            guard let button = $0 as? PressFXView else { return }
            if let option = button.getOption(), option  == .myManager {
                button.showNotificationBadge(visible)
            }
        }
    }
}

private extension OptionsBarView {
    func bind() {
        optionsSubject
            .sink { [unowned self] options in
                self.setOptions(options)
            }.store(in: &anySubscriptions)
        
        personalManagerBadgeSubject
            .sink { [unowned self] _ in
                self.setNotificationBadgeVisible(true)            
            }
            .store(in: &anySubscriptions)
        
        personalManagerImageSubject.sink { [unowned self] image in
            self.setManagerImage(image)
        }.store(in: &anySubscriptions)
    }
    
    func setManagerImage(_ image: UIImage) {
        containerStackView.arrangedSubviews.forEach {
            guard let button = $0 as? PressFXView else { return }
            if let option = button.getOption(), option  == .myManager {
                button.updateManagerImage(image)
            }
        }
    }
}
