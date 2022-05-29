import Foundation

final public class ChangePasswordConfiguration {
    let message: String
    let maxLength: Int
    let minLength: Int
    let keyboardType: UIKeyboardType
    
    public init(message: String, maxLength: Int, minLength: Int, keyboardType: UIKeyboardType) {
        self.message = message
        self.maxLength = maxLength
        self.minLength = minLength
        self.keyboardType = keyboardType
    }
}
