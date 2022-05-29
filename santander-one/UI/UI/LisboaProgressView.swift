import UIKit

public class LisboaProgressView: UIView {
    
    private var progressBar: SteppedProgressBar?
    private var totalSteps: Int = 1
    private var currentStep: Int = 0
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: progressBarType?.segmentMargin ?? SteppedProgressBar.Contants.defaultSegmentMargin).isActive = true
        return view
    }()
    public var progressBarType: ProgressBarType?

    private func updateSteps(animated: Bool) {
        guard self.totalSteps > 1  else {
            self.progressBar?.setOnlyOneStep()
            return
        }
        self.progressBar?.setSteps(self.totalSteps) {
            DispatchQueue.main.async {
                self.progressBar?.go(to: self.currentStep, animated: animated)
            }
        }
    }
    
    // MARK: - Public Funcs
    
    public func configure(background: UIColor, fill: UIColor) {
        let progressBar = SteppedProgressBar(frame: .zero)
        progressBar.configure(unfilledColor: background, filledColor: fill, progressBarType: progressBarType)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundView)
        self.addSubview(progressBar)
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressBar.fullFit()
        self.progressBar = progressBar
        updateSteps(animated: false)
    }
    
    public func setTopBackgroundColor(_ color: UIColor?) {
        self.backgroundView.backgroundColor = color ?? .skyGray
    }
    
    func moreStep() {
        totalSteps += 1
        updateSteps(animated: false)
    }
    
    func lessStep() {
        totalSteps -= 1
        updateSteps(animated: false)
    }
    
    public func nextStep() {
        currentStep += 1
        updateSteps(animated: true)
    }
    
    public func previousStep(animated: Bool = true) {
        currentStep -= 1
        updateSteps(animated: animated)
    }
    
    public func updateSteps(current: Int, total: Int) {
        currentStep = current
        totalSteps = total
        updateSteps(animated: true)
    }
    
    public func updateTotal(total: Int) {
        totalSteps = total
        updateSteps(animated: true)
    }

    public func updateCurrent(current: Int, animated: Bool = true) {
        currentStep = current
        updateSteps(animated: animated)
    }
}
