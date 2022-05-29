import Foundation
import CoreFoundationLib

struct BizumMultimediaData {
    var image: Data?
    var note: String?

    func hasSomeValue() -> Bool {
        return ([image, note] as [Any?]).contains(where: { $0 != nil })
    }
}

protocol BizumMultimediaViewProtocol: class {
    var onImageTapped: () -> Void { get set}
    var onDeleteNoteTapped: () -> Void { get set }
    var onDeleteImageTapped: () -> Void { get set }
    var noteWasUpdate: (_ text: String) -> Void { get set }
    var noteBeginEditing: () -> Void { get set }
    
    func preloadNote(_ text: String)
    func updateView()
    func showThumbnailImage(data: Data)
    func hideThumbnailImage()
    func setImageTitle(_ name: String)
    func setDescriptionNote(_ description: String)
    func showNote()
    func hideNote()
    func showEdit()
    func hideEdit()
    func showDeleteNote()
    func hideDeleteNote()
    func showDeleteImage()
    func hideDeleteImage()
    func showCamera()
    func hideCamera()
    func clearNoteTextColor()
    func setNoteTextColorGrafite()
    func changeStyleNewImage()
    func changeStyleEmptyImage()
}

final class BizumMultimediaViewModel {
    weak var galleryActionsDelegate: BizumMultimediaGalleryDelegate?
    private (set) var multimediaData: BizumMultimediaData = BizumMultimediaData()
    private let linkImage: String = localized("addImage_label_viewImage")
    private let placeHolder: String = localized("addNote_label_addNote")
    private weak var view: BizumMultimediaViewProtocol?
    
    init(multimediaData: BizumMultimediaData?) {
        self.multimediaData = multimediaData ?? BizumMultimediaData()
    }

    func update(view: BizumMultimediaViewProtocol) {
        self.view = view
        view.updateView()
        preloadMultimediaDataIfAvailable()
        view.noteWasUpdate = { [weak self] newText in
            if newText.isEmpty {
                self?.multimediaData.note = nil
                view.setDescriptionNote(self?.placeHolder ?? "")
                view.clearNoteTextColor()
                view.showEdit()
                view.hideNote()
                view.hideDeleteNote()
            } else {
                self?.multimediaData.note = newText
                view.setNoteTextColorGrafite()
                view.showEdit()
                view.showNote()
                view.showDeleteNote()
            }
        }
        view.noteBeginEditing = {
            view.hideEdit()
            view.hideNote()
            view.hideDeleteNote()
        }
        view.onDeleteImageTapped = { [weak self] in
            self?.multimediaData.image = nil
            view.setImageTitle(localized("addImage_label_addImage"))
            view.changeStyleEmptyImage()
            view.showCamera()
            view.hideThumbnailImage()
            view.hideDeleteImage()
        }
        view.onDeleteNoteTapped = { [weak self] in
            self?.multimediaData.note = nil
            view.setDescriptionNote(self?.placeHolder ?? "")
            view.clearNoteTextColor()
            view.showEdit()
            view.hideNote()
            view.hideDeleteNote()
        }
        view.onImageTapped = { [weak self] in
            if self?.multimediaData.image != nil {
                self?.openImageDetail()
            } else {
                self?.galleryActionsDelegate?.cameraWasTapped()
            }
        }
    }

    func showThumbnailImage(_ image: Data) {
        self.multimediaData.image = image
        self.view?.showThumbnailImage(data: image)
        self.view?.showDeleteImage()
        self.view?.hideCamera()
        self.view?.setImageTitle(self.linkImage)
        self.view?.changeStyleNewImage()
    }
}

// MARK: - Private
private extension BizumMultimediaViewModel {
    func openImageDetail() {
        guard let dataImage = self.multimediaData.image else { return }
        self.galleryActionsDelegate?.openImageDetail(dataImage)
    }
    func preloadMultimediaDataIfAvailable() {
        if let noteText = multimediaData.note {
            self.view?.preloadNote(noteText)
        }
        if let imageData = multimediaData.image {
            self.view?.showThumbnailImage(data: imageData)
            self.view?.showDeleteImage()
            self.view?.hideCamera()
            self.view?.setImageTitle(self.linkImage)
            self.view?.changeStyleNewImage()
        }
    }
}
