import UIKit

public func showManager(image: String, container: UIImageView) {
    let catPictureURL = URL(string: "https://microsite.bancosantander.es/filesFF/apps/SAN/imgGP/"+image+".jpg")!
    
//    let catPictureURL = URL(string: "https://wordsmith.org/words/images/avatar2_large.png")!
    // Creating a session object with the default configuration.
    // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
    let session = URLSession(configuration: .default)
    
    // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
    let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
        // The download has finished.
        if error != nil {
            DispatchQueue.main.async {
                container.image = UIImage(named: "avatar_san")
            }
        } else {
            // No errors found.
            // It would be weird if we didn't have a response, so check for that too.
            if let res = response as? HTTPURLResponse {
                if let imageData = data {
                    // Finally convert that Data into an image and do what you wish with it.
                    if let image = UIImage(data: imageData) {
                        // Do something with your image.
                        DispatchQueue.main.async {
                            container.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            container.image = UIImage(named: "avatar_san")
                        }
                    }
                    if res.statusCode == 404 {
                        DispatchQueue.main.async {
                            container.image = UIImage(named: "avatar_san")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        container.image = UIImage(named: "avatar_san")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    container.image = UIImage(named: "avatar_san")
                }
            }
        }
    }
    downloadPicTask.resume()
}
