import CoreFoundationLib

protocol CoachmarkPresenterType: CoachmarkPresenter {
    associatedtype View: UIViewController
    var view: View { get }
    var useCaseProvider: UseCaseProvider { get }
    var useCaseHandler: UseCaseHandler { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
}

extension CoachmarkPresenterType {
    
    func resetCoachmarks() {
        viewPositions = [CoachmarkIdentifier: IntermediateRect]()
    }
    
    private func displayCoachmarks(_ coachmarkIds: [CoachmarkIdentifier]) {
        guard viewPositions.count == neededIdentifiers.count,
            (viewPositions.filter { $0.value != IntermediateRect.zero }.count) > 0 else {
                coachmarkDidDismiss()
                return
        }
        
        UseCaseWrapper(with: useCaseProvider.setCoachmarkSeen(input: SetCoachmarkSeenInput(coachmarkIds: coachmarkIds)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler)
        Coachmark.present(source: view, presenter: self)
    }
    
    private func displayValid(_ coachmarks: [CoachmarkIdentifier: IntermediateRect]) {
        var coachmarksToSet = [CoachmarkIdentifier]()
        for coachmark in coachmarks where coachmark.value != IntermediateRect.zero {
            if !coachmarksToSet.contains(coachmark.key) {
                coachmarksToSet.append(coachmark.key)
            }
            self.viewPositions[coachmark.key] = coachmark.value
        }
        if coachmarksToSet.count > 0 {
            Coachmark.present(source: view, presenter: self)
        }
    }
    
    func setCoachmarks(coachmarks: [CoachmarkIdentifier: IntermediateRect], isForcedCoachmark: Bool = false) {
        let coachmarksToSet = ThreadSafeProperty([CoachmarkIdentifier]())
        guard !coachmarks.isEmpty else {
            displayCoachmarks(coachmarksToSet.value)
            return
        }
        
        if isForcedCoachmark {
            displayValid(coachmarks)
            return
        }
        
        let processGroup = DispatchGroup()
        for coachmark in coachmarks {
            processGroup.enter()
            UseCaseWrapper(with: useCaseProvider.isCoachmarkSeen(input: GetCoachmarkStatusUseCaseInput(coachmarkId: coachmark.key)), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] result in
                defer {
                    processGroup.leave()
                }
                
                if !result.status && coachmark.value != IntermediateRect.zero {
                    if coachmarksToSet.value.contains(coachmark.key) == false {
                        coachmarksToSet.value.append(coachmark.key)
                    }
                    self?.viewPositions[coachmark.key] = coachmark.value
                } else {
                    self?.viewPositions[coachmark.key] = IntermediateRect.zero
                }
            })
        }
        processGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.displayCoachmarks(coachmarksToSet.value)
        }
    }
}
