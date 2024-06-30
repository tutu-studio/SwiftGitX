import libgit2

// ? Should we use actor?
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

    /// Sets a configuration value for the repository.
    ///
    /// - Parameters:
    ///   - string: The value to set.
    ///   - key: The key to set the value for.
    ///
    /// This will set the configuration value for the repository.
    public func set(_ string: String, forKey key: String) {
        var configPointer: OpaquePointer?
        defer { git_config_free(configPointer) }

        git_repository_config(&configPointer, repositoryPointer)

        guard let configPointer else {
            // TODO: Handle error
            return
        }

        git_config_set_string(configPointer, key, string)
    }

    /// Returns the configuration value for the repository.
    ///
    /// - Parameter key: The key to get the value for.
    ///
    /// - Returns: The configuration value for the key.
    ///
    /// All config files will be looked into, in the order of their defined level. A higher level means a higher
    /// priority. The first occurrence of the variable will be returned here.
    public func string(forKey key: String) -> String? {
        var configPointer: OpaquePointer?
        defer { git_config_free(configPointer) }

        git_repository_config(&configPointer, repositoryPointer)

        guard let configPointer else {
            // TODO: Handle error
            return nil
        }

        var valueBuffer = git_buf()
        defer { git_buf_free(&valueBuffer) }

        let status = git_config_get_string_buf(&valueBuffer, configPointer, key)

        guard let pointer = valueBuffer.ptr, status == GIT_OK.rawValue else {
            return nil
        }

        return String(cString: pointer)
    }
}
