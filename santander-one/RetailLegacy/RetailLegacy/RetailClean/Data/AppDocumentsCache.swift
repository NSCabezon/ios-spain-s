import Foundation

struct AppDocument {
    let data: Data
    let url: URL
}

protocol AppDocumentsCache {
    func persist(document: Data, withFileName fileName: String)
    func obtainDocument(withFileName fileName: String) -> AppDocument?
    func remove()
}

class AppDocumentsCacheImpl {
    private let created = false
    private let destination: URL
    
    init(absolutePath: String) {
        self.destination = URL(fileURLWithPath: absolutePath)
    }
    
    init(relativePath destination: String) {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        self.destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(destination, isDirectory: true)
    }
    
    func create() {
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }
}
    
extension AppDocumentsCacheImpl: AppDocumentsCache {
    
    func persist(document: Data, withFileName fileName: String) {
        if !created {
            create()
        }
        let url = destination.appendingPathComponent(fileName, isDirectory: false)
        
        do {
            try document.write(to: url, options: [.atomicWrite])
        } catch {
            fatalError("Unable to create cache at url: \(url)")
        }
    }
    
    func obtainDocument(withFileName fileName: String) -> AppDocument? {
        if !created {
            create()
        }
        let url = destination.appendingPathComponent(fileName, isDirectory: false)
        guard let data = try? Data(contentsOf: url), data.bytes.count > 0 else {
            return nil
        }
        return AppDocument(data: data, url: url)
    }
    
    func remove() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destination)
        } catch {
            fatalError("Unable to remove cached data")
        }
    }
}
