import UIKit
import UI

class NavigatorProgressBar: UIView {
    
    private weak var progressView: LisboaProgressView?
    private var observationTotal: NSKeyValueObservation?
    private var observationCurrent: NSKeyValueObservation?
    private var progress: Progress?
    
    // MARK: - Class Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    // MARK: - Public Functions
    
    func updateProgressBar() {
        self.observationTotal?.invalidate()
        self.observationCurrent?.invalidate()
        self.setupView()
        self.setProgress(self.progress)
    }
    
    func setProgress(_ progress: Progress?) {
        self.observationTotal?.invalidate()
        self.observationCurrent?.invalidate()
        if let total = progress?.totalUnitCount, total != self.progress?.totalUnitCount {
            self.progressView?.updateTotal(total: Int(total))
        }
        if let completedCount = progress?.completedUnitCount, completedCount != self.progress?.completedUnitCount {
            self.progressView?.updateCurrent(current: Int(completedCount))
        }
        self.progress = progress
        self.observationTotal = progress?.observe(\.totalUnitCount, changeHandler: { [weak self] (progress, _) in
            self?.progressView?.updateTotal(total: Int(progress.totalUnitCount))
        })
        self.observationCurrent = progress?.observe(\.completedUnitCount, changeHandler: { [weak self] (progress, _) in
            self?.progressView?.updateCurrent(current: Int(progress.completedUnitCount))
        })
    }
    
    func setTopBackgroundViewColor(_ color: UIColor) {
        self.progressView?.setTopBackgroundColor(color)
    }
    
    // MARK: - Private Functions
    
    private func createProgressView() {
        let progressView = LisboaProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        progressView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        progressView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        superview?.layoutIfNeeded()
        progressView.configure(background: UIColor.lisboaGray, fill: UIColor.bostonRed)
        self.progressView = progressView
    }
    
    private func setupView() {
        guard self.progressView == nil else { return }
        createProgressView()
    }
}
