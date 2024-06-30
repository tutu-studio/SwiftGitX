import libgit2

/// Represents the differences between two trees.
public struct Diff: Equatable, Hashable {
    /// The changes in the diff
    public let changes: [Delta]

    init(pointer: OpaquePointer) {
        var deltas = [Delta]()

        // Get the number of deltas in the diff
        let numberOfDeltas = git_diff_num_deltas(pointer)

        // Iterate over the deltas and append them to the array
        for index in 0 ..< numberOfDeltas {
            let deltaPointer = git_diff_get_delta(pointer, index)

            guard let rawDelta = deltaPointer?.pointee else {
                continue
            }

            // Create a new delta from the raw delta
            let delta = Delta(raw: rawDelta)

            deltas.append(delta)
        }

        changes = deltas
    }
}

// MARK: - Structs

public extension Diff {
    struct Delta: LibGit2RawRepresentable {
        /// The status of the delta.
        public let status: Status

        /// The `oldFile` represents the "from" side of the diff.
        public let oldFile: File

        /// The `newFile` represents the "to" side of the diff.
        public let newFile: File

        /// The flags of the delta.
        public let flags: [Flag]

        /// The similarity between the files for "renamed" or "copied" status (0-100).
        public let similarity: Int

        /// The number of files in the delta.
        public let numberOfFiles: Int

        // Represents git_diff_file in libgit2.
        let raw: git_diff_delta

        init(raw: git_diff_delta) {
            status = Status(rawValue: Int(raw.status.rawValue))!

            oldFile = File(raw: raw.old_file)
            newFile = File(raw: raw.new_file)

            flags = Flag.from(raw.flags)
            similarity = Int(raw.similarity)
            numberOfFiles = Int(raw.nfiles)

            self.raw = raw
        }

        public static func == (lhs: Diff.Delta, rhs: Diff.Delta) -> Bool {
            lhs.status == rhs.status &&
                lhs.oldFile == rhs.oldFile &&
                lhs.newFile == rhs.newFile &&
                lhs.flags == rhs.flags &&
                lhs.similarity == rhs.similarity &&
                lhs.numberOfFiles == rhs.numberOfFiles
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(status)
            hasher.combine(oldFile)
            hasher.combine(newFile)
            hasher.combine(flags)
            hasher.combine(similarity)
            hasher.combine(numberOfFiles)
        }
    }

    struct File: LibGit2RawRepresentable {
        /// The ID of the object.
        public let id: OID

        /// The path of the file relative to the repository working directory.
        public let path: String

        /// The size of the entry in bytes.
        public let size: Int

        /// The flags of the file.
        public let flags: [Flag]

        /// The mode of the file.
        public let mode: FileMode

        let raw: git_diff_file

        init(raw: git_diff_file) {
            id = OID(raw: raw.id)
            path = String(cString: raw.path)
            size = Int(raw.size)
            flags = Flag.from(raw.flags)
            mode = FileMode(raw: git_filemode_t(rawValue: UInt32(raw.mode)))

            self.raw = raw
        }

        public static func == (lhs: Diff.File, rhs: Diff.File) -> Bool {
            lhs.id == rhs.id &&
                lhs.path == rhs.path &&
                lhs.size == rhs.size &&
                lhs.flags == rhs.flags &&
                lhs.mode == rhs.mode
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(path)
            hasher.combine(size)
            hasher.combine(flags)
            hasher.combine(mode)
        }
    }
}

// MARK: - Enums

public extension Diff {
    // Represents git_diff_flag_t enum in libgit2
    enum Flag {
        /// The file is binary.
        case binary

        /// The file is not binary.
        case notBinary

        /// The file id is valid.
        case validID

        /// The file exists at this side of the delta.
        case exists

        /// The file size is valid.
        case validSize

        static func from(_ flags: UInt32) -> [Flag] {
            var result = [Flag]()

            if flags & GIT_DIFF_FLAG_BINARY.rawValue != 0 {
                result.append(.binary)
            }

            if flags & GIT_DIFF_FLAG_NOT_BINARY.rawValue != 0 {
                result.append(.notBinary)
            }

            if flags & GIT_DIFF_FLAG_VALID_ID.rawValue != 0 {
                result.append(.validID)
            }

            if flags & GIT_DIFF_FLAG_EXISTS.rawValue != 0 {
                result.append(.exists)
            }

            if flags & GIT_DIFF_FLAG_VALID_SIZE.rawValue != 0 {
                result.append(.validSize)
            }

            return result
        }
    }
}

public extension Diff.Delta {
    // Represents git_delta_t enum in libgit2
    enum Status: Int {
        /// No changes
        case unmodified = 0

        /// Entry does not exist in old version
        case added

        /// Entry does not exist in new version
        case deleted

        /// Entry content changed between old and new
        case modified

        /// Entry was renamed between old and new
        case renamed

        /// Entry was copied from another old entry
        case copied

        /// Entry is ignored item in working tree
        case ignored

        /// Entry is untracked item in working tree
        case untracked

        /// Type of entry changed between old and new
        case typeChange

        /// Entry is unreadable
        case unreadable

        /// Entry in the index is conflicted
        case conflicted
    }
}
