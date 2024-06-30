import libgit2

/// A collection of configurations and their operations.
public struct ConfigCollection {
    private let repositoryPointer: OpaquePointer

    init(repositoryPointer: OpaquePointer) {
        self.repositoryPointer = repositoryPointer
    }

    /// The default branch name of the repository
    ///
    /// - Returns: The default branch name of the repository
    ///
    /// This is the branch that is checked out when the repository is initialized.
    public var defaultBranchName: String {
        var configPointer: OpaquePointer?
        defer { git_config_free(configPointer) }

        git_repository_config(&configPointer, repositoryPointer)

        var branchNameBuffer = git_buf()
        defer { git_buf_free(&branchNameBuffer) }

        git_config_get_string_buf(&branchNameBuffer, configPointer, "init.defaultBranch")

        return String(cString: branchNameBuffer.ptr)
    }
}
