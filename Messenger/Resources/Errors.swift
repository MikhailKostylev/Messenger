import Foundation

public enum LoginError: Error {
    case incompleteForm
    case invalidEmail
    case incorrectPasswordLength
}

public enum StorageErrors: Error {
    case failedToUpload
    case failedToDownloadUrl
}

public enum DatabaseErrors: Error {
    case failedToFetch
}
