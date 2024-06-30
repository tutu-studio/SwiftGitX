import Foundation

extension URL {
    /// An error thrown when the URL is not a descendant of the base URL.
    enum RelativePathError: Error {
        /// The URL is not a descendant of the base URL.
        case notDescendantOfBase
    }

    /// Returns the relative path of the URL.
    ///
    /// - Parameter base: The base URL to get the relative path from.
    ///
    /// - Returns: The relative path of the URL.
    ///
    /// - Throws: An error if the URL is not a descendant of the base URL.
    func relativePath(from base: URL) throws -> String {
        guard path.hasPrefix(base.path) else {
            throw RelativePathError.notDescendantOfBase
        }

        var relativePath = String(path.dropFirst(base.path.count))
        if relativePath.hasPrefix("/") {
            relativePath = String(relativePath.dropFirst())
        }

        return relativePath
    }
}
