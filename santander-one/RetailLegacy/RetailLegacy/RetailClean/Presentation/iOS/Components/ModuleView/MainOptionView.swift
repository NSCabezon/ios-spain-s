import UIKit

extension ModuleMenuView {
    
    class MainOptionView: UIView, CoachmarkUIView {
        
        var coachmarkId: CoachmarkIdentifier?
        private var shadowViews = [UIView]()
        private var executeAction: ModuleMenuExecutableOptionType?
        private lazy var mainOptionTitleView: MainTitleView = {
            let view = MainTitleView()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            return view
        }()
        
        private lazy var mainOptionButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        private lazy var mainOptionStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.distribution = .fill
            stackView.alignment = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            return stackView
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
            backgroundColor = .uiWhite
            addSubview(mainOptionStackView)
            mainOptionStackView.topAnchor.constraint(equalTo: topAnchor, constant: 13).isActive = true
            mainOptionStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -13).isActive = true
            mainOptionStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            mainOptionStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            mainOptionStackView.addArrangedSubview(mainOptionTitleView)
            mainOptionButton.embedInto(container: self)
            mainOptionButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        }
        
        // MARK: - life cycle
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            for v in shadowViews {
                v.drawRoundedAndShadowed()
            }
        }
        
        // MARK: - public
        
        func setMainOption(_ option: ModuleMenuMainOptionType) {
            setTitle(option.title)
            setImageKey(option.imageKey)
            coachmarkId = option.coachmarkId
            addRows(option.rows)
            executeAction = option
        }
        
        private func setTitle(_ title: LocalizedStylableText) {
            mainOptionTitleView.setTitle(title)
        }
        
        private func setImageKey(_ imageKey: String) {
            mainOptionTitleView.setImageKey(imageKey)
        }
        
        private func addRow(_ title: LocalizedStylableText) {
            let wrapperView = UIView()
            wrapperView.backgroundColor = .clear
            wrapperView.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            wrapperView.addSubview(label)
            label.embedInto(container: wrapperView, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
            label.numberOfLines = 3
            label.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 13.0), textAlignment: .left))
            label.set(localizedStylableText: title)
            
            mainOptionStackView.addArrangedSubview(wrapperView)
        }
        
        private func addRows(_ titles: [LocalizedStylableText]) {
            for title in titles {
                addRow(title)
            }
        }
        
        @objc func buttonPressed() {
            executeAction?.execute()
        }
    }
    
}
