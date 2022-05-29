import Operative

class FakeOperativeFinishingCoordinator: OperativeFinishingCoordinator {
    func didFinishSuccessfully(_ coordinator: OperativeContainerCoordinatorProtocol, operative: Operative) {
        coordinator.navigationController?.popToRootViewController(animated: true)
    }
}
