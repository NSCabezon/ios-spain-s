import UIKit
import UI

extension ModuleMenuView {
    
    class MainTitleView: UIView, CoachmarkUIView {
        
        var coachmarkId: CoachmarkIdentifier?
        
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 6
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            return stackView
        }()
        
        private lazy var imageView: UIImageView = {
            let image = UIImageView()
            image.contentMode = .center
            image.translatesAutoresizingMaskIntoConstraints = false
            image.setContentHuggingPriority(.required, for: .horizontal)
            
            return image
        }()
        
        private lazy var label: UILabel = {
            let label = UILabel()
            label.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 22.0), textAlignment: .left))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.minimumScaleFactor = 0.4
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 2
            
            return label
        }()
        
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
            stackView.embedInto(container: self)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
        }
        
        // MARK: - public
        
        func setImageKey(_ imageKey: String) {
            imageView.image = Assets.image(named: imageKey)
        }
        
        func setTitle(_ title: LocalizedStylableText) {
            label.set(localizedStylableText: title)
        }
        
    }
    
}
