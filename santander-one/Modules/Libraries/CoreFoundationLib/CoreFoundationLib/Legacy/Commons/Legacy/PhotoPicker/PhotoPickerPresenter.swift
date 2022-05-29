public protocol PhotoPickerPresenter: PhotoHelperDelegate {
    func selected(image: Data)
}

public extension PhotoPickerPresenter {
    func selectedImage(image: Data) {
        selected(image: image)
    }
}
