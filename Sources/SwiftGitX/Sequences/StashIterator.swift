public struct StashIterator: IteratorProtocol {
    private var index = 0
    private let entries: [StashEntry]

    init(entries: [StashEntry]) {
        self.entries = entries
    }

    public mutating func next() -> StashEntry? {
        guard index < entries.count else { return nil }

        defer { index += 1 }

        return entries[index]
    }
}
