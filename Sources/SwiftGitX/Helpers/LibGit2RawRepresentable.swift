/// An internal protocol for types that can be represented by a raw libgit2 struct.
protocol LibGit2RawRepresentable: Equatable, Hashable {
    associatedtype RawType

    /// Initializes the type with a raw libgit2 struct.
    ///
    /// - Parameter raw: The raw libgit2 struct.
    init(raw: RawType)
}
