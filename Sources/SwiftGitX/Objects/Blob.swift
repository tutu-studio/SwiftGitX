import Foundation
import libgit2

public enum BlobError: Error {
    case invalid(String)
}

/// A blob object representation in the repository.
///
/// A blob object is a binary large object that stores the content of a file.
public struct Blob: Object {
    /// The id of the blob.
    public let id: OID

    /// The content of the blob.
    public let content: Data

    /// The type of the object.
    public let type: ObjectType = .blob

    init(pointer: OpaquePointer) throws {
        let id = git_blob_id(pointer).pointee

        // ? Should we make it a computed property?
        let content = git_blob_rawcontent(pointer)

        guard let content else {
            let errorMessage = String(cString: git_error_last().pointee.message)
            throw BlobError.invalid(errorMessage)
        }

        self.id = OID(raw: id)
        self.content = Data(bytes: content, count: Int(git_blob_rawsize(pointer)))
    }
}
