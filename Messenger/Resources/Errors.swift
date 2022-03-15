import Foundation

public enum LoginError: Error {
    case incompleteForm
    case invalidEmail
    case incorrectPasswordLength
}
