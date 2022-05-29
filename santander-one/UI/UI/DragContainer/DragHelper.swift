//
//  DragHelper.swift
//  UI
//
//  Created by David Gálvez Alonso on 05/08/2020.
//

import CoreFoundationLib

public protocol DragHelper: AnyObject {
    var dragContainer: DragContainer! { get set }
    var viewModelsScrollView: UIScrollView! { get set }
    var topStackView: ActionButtonsStackView<GpOperativesViewModel> { get set }
    var bottomStackView: ActionButtonsStackView<GpOperativesViewModel> { get set }
    var isEditingEnable: Bool { get set }
    var viewModels: [GpOperativesViewModel]? { get set }
}

public extension DragHelper {

    func createdCopy(_ copy: UIView, actionButton: DragButton) {
        dragContainer.addSubviewCopy(copy, actionButton: actionButton)
        viewModelsScrollView.isScrollEnabled = false
        HapticTrigger.alert()
    }

    func handleButtonGesture(sender: UIGestureRecognizer, actionButton: DragButton) {
        guard self.isEditingEnable else { return }
        
        checkScroll(sender: sender, actionButton: actionButton)
        dragContainer.handleButtonGesture(sender: sender, actionButton: actionButton)

        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
            guard let actionButtonVieModel = actionButton.getViewModel() as? GpOperativesViewModel,
            let copyViewModel = (dragContainer.copyView as? DragButton)?.getViewModel() as? GpOperativesViewModel,
            actionButtonVieModel.viewType == copyViewModel.viewType else { return }

            handleEndedGesture(sender: sender, actionButton: actionButton)
        }
    }
}

private extension DragHelper {
    
    func handleEndedGesture(sender: UIGestureRecognizer, actionButton: DragButton) {
        let pointedButton = didEndDrag(recognizer: sender, actionButton: actionButton)
        
        if let pointedButton = pointedButton, let pointedButtonCopy = pointedButton.createCopy() as? DragButton, let actionButtonCopy = actionButton.createCopy() as? DragButton {
            actionButton.swapButton(actionButton: pointedButtonCopy)
            dragContainer.swapButton(pointedButton: pointedButtonCopy)
            pointedButton.swapButton(actionButton: actionButtonCopy)
        }
        animateEndDrop(actionButton: actionButton, pointedButton: pointedButton)
        viewModelsScrollView.isScrollEnabled = true
    }
    
    func checkScroll(sender: UIGestureRecognizer, actionButton: DragButton) {
        guard let position = (sender as? UIPanGestureRecognizer)?.translation(in: viewModelsScrollView) else { return }
        
        let verticalPoint = (viewModelsScrollView.frame.size.height / 2) - actionButton.convert(position, to: viewModelsScrollView).y
        let maxScroll = viewModelsScrollView.contentSize.height - viewModelsScrollView.bounds.size.height
        let limitVerticalPosition = max(0.0, min(viewModelsScrollView.contentOffset.y - verticalPoint/5, maxScroll))
        let newContentOffset = CGPoint(x: viewModelsScrollView.contentOffset.x, y: limitVerticalPosition)
        let difference = limitVerticalPosition - viewModelsScrollView.contentOffset.y
        
        guard difference != 0 else { return }
        let animated = sender.state == .began ? true : false

        viewModelsScrollView.setContentOffset(newContentOffset, animated: animated)
        updateCopyView(actionButton: actionButton, difference: difference)
    }
    
    func updateCopyView(actionButton: DragButton, difference: CGFloat) {
        guard getIndexOfModel(button: actionButton) ?? 0 >= 4 else { return }
        
        dragContainer.updateCopyView(position: difference)
    }
    
    func animateEndDrop(actionButton: DragButton, pointedButton: DragButton?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.dragContainer.moveCopyToOrigin(actionButton: actionButton)
        }, completion: { _ in
            self.dragContainer.resetView()
            actionButton.resetView()
            pointedButton?.resetView()
        })
    }
    
    func getTargetButton(recognizer: UIGestureRecognizer) -> DragButton? {
        let pointTopStackView = recognizer.location(in: topStackView)
        let pointBottomStackView = recognizer.location(in: bottomStackView)
        let selectedStackView = topStackView.frame.contains(pointTopStackView) ? topStackView : bottomStackView.frame.contains(pointBottomStackView) ? bottomStackView : nil
        guard let stackView = selectedStackView else { return nil }
        let point = recognizer.location(in: stackView)
        var subviewPointed: DragButton?
        stackView.subviews.forEach { (stackSubview) in
            if stackSubview.frame.contains(point) {
                let pointInStackView = recognizer.location(in: stackSubview)
                let allSubviews = stackSubview.getAllSubviews()
                let dragButtons = allSubviews.filter { $0 is DragButton }
                dragButtons.forEach { (actionButton) in
                    if let actionButtonPointed = actionButton as? DragButton, actionButtonPointed.frame.contains(pointInStackView) {
                        subviewPointed = actionButtonPointed
                    }
                }
            }
        }
        
        return subviewPointed?.isDragDisabled ?? true ? nil : subviewPointed
    }
    
    func swapModels(actionButton: DragButton, pointedButton: DragButton) {
        guard let dropIndex = getIndexOfModel(button: pointedButton) else { return }
        guard let dragIndex = getIndexOfModel(button: actionButton) else { return }
        
        if var swapedViewModels = viewModels {
            swapedViewModels.swapAt(dragIndex, dropIndex)
            self.viewModels = swapedViewModels
        }
    }
    
    func getIndexOfModel(button: DragButton) -> Int? {
        guard let viewModels = viewModels else { return nil }
        guard let viewModel = button.getViewModel() as? GpOperativesViewModel else { return nil }
        return viewModels.firstIndex { $0 === viewModel }
    }
    
    func didEndDrag(recognizer: UIGestureRecognizer, actionButton: DragButton) -> DragButton? {
        HapticTrigger.alertMedium()
        if let pointedButton = getTargetButton(recognizer: recognizer), actionButton != pointedButton {
            swapModels(actionButton: actionButton, pointedButton: pointedButton)
            
            return pointedButton
        }
        return nil
    }
}

extension GpOperativesViewModel: ActionButtonViewModelProtocol {
    public var accessibilityIdentifier: String? {
        return type.accessibilityIdentifier
    }
    
    public var actionType: PGFrequentOperativeOptionProtocol {
        return self.type
    }
}
