import libgit2

/// Represents the status of a file in the repository.
public struct StatusEntry: LibGit2RawRepresentable {
    /// The status of the file.
    public let status: Status

    /// The differences between the file in HEAD and the file in the index.
    ///
    /// This represents the changes that have been staged but not committed.
    /// If the file is not staged, this is `nil`.
    public let index: Diff.Delta?

    /// The differences between the file in the index and the file in the working directory.
    ///
    /// This represents the changes on working tree that are not staged.
    /// If the file is staged and there is no additional changes, this is `nil`.
    public let workingTree: Diff.Delta?

    init(raw: git_status_entry) {
        status = Status(raw: raw.status)

        index = if let rawDelta = raw.head_to_index?.pointee {
            Diff.Delta(raw: rawDelta)
        } else { nil }

        workingTree = if let rawDelta = raw.index_to_workdir?.pointee {
            Diff.Delta(raw: rawDelta)
        } else { nil }
    }

    /// Represents the status of a file in the repository.
    public enum Status: LibGit2RawRepresentable {
        case current

        case indexNew
        case indexModified
        case indexDeleted
        case indexRenamed
        case indexTypeChange

        case workingTreeNew
        case workingTreeModified
        case workingTreeDeleted
        case workingTreeTypeChange
        case workingTreeRenamed
        case workingTreeUnreadable

        case ignored
        case conflicted

        var raw: git_status_t {
            Status.statusMapping[self] ?? GIT_STATUS_CURRENT
        }

        init(raw: git_status_t) {
            self = Status.statusMapping.first(where: { $0.value == raw })?.key ?? .current
        }

        static func from(_ flags: UInt32) -> [Status] {
            Status.statusMapping.filter { flags & $0.value.rawValue != 0 }.map(\.key)
        }
    }
}

private extension StatusEntry.Status {
    static let statusMapping: [StatusEntry.Status: git_status_t] = [
        .current: GIT_STATUS_CURRENT,

        .indexNew: GIT_STATUS_INDEX_NEW,
        .indexModified: GIT_STATUS_INDEX_MODIFIED,
        .indexDeleted: GIT_STATUS_INDEX_DELETED,
        .indexRenamed: GIT_STATUS_INDEX_RENAMED,
        .indexTypeChange: GIT_STATUS_INDEX_TYPECHANGE,

        .workingTreeNew: GIT_STATUS_WT_NEW,
        .workingTreeModified: GIT_STATUS_WT_MODIFIED,
        .workingTreeDeleted: GIT_STATUS_WT_DELETED,
        .workingTreeTypeChange: GIT_STATUS_WT_TYPECHANGE,
        .workingTreeRenamed: GIT_STATUS_WT_RENAMED,
        .workingTreeUnreadable: GIT_STATUS_WT_UNREADABLE,

        .ignored: GIT_STATUS_IGNORED,
        .conflicted: GIT_STATUS_CONFLICTED
    ]
}
