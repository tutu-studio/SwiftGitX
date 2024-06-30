import SwiftGitX
import XCTest

final class RepositoryRemoteOperationTests: SwiftGitXTestCase {
    func testRepositoryPush() async throws {
        // Create a mock repository at the temporary directory
        let source = URL(string: "https://github.com/ibrahimcetin/ibrahimcetin.dev.git")!
        let remoteDirectory = Repository.mockDirectory(named: "test-push--remote", in: Self.directory)
        let remoteRepository = try await Repository.clone(from: source, to: remoteDirectory, options: .bare)

        // Clone the remote repository to the local repository
        let localDirectory = Repository.mockDirectory(named: "test-push--local", in: Self.directory)
        let localRepository = try await Repository.clone(from: remoteDirectory, to: localDirectory)

        // Update the configuration to use the current user's name and email
        localRepository.config.set("İbrahim Çetin", forKey: "user.name")
        localRepository.config.set("mail@ibrahimcetin.dev", forKey: "user.email")

        // Create a new commit in the local repository
        try localRepository.mockCommit(message: "Pushed commit", file: localRepository.mockFile(named: "PushedFile.md"))

        // Push the commit to the remote repository
        try await localRepository.push()

        // Check if the commit is pushed
        try XCTAssertEqual(localRepository.HEAD.target.id, remoteRepository.HEAD.target.id)
    }

    func testRepositoryPushEmptyRemote_SetUpstream() async throws {
        // Create a mock repository at the temporary directory
        let remoteDirectory = Repository.mockDirectory(named: "test-push-empty--remote", in: Self.directory)
        let remoteRepository = try Repository.create(at: remoteDirectory, isBare: true)

        // Create a mock repository at the temporary directory
        let localRepository = Repository.mock(named: "test-push-empty--local", in: Self.directory)

        // Create a new commit in the local repository
        try localRepository.mockCommit(message: "Pushed commit", file: localRepository.mockFile(named: "PushedFile.md"))

        // Add remote repository to the local repository
        try localRepository.remote.add(named: "origin", at: remoteDirectory)

        // Push the commit to the remote repository
        try await localRepository.push()

        // Check if the commit is pushed
        try XCTAssertEqual(localRepository.HEAD.target.id, remoteRepository.HEAD.target.id)

        // Upstream branch should be nil
        try XCTAssertNil(localRepository.branch.current.upstream)

        // Set the upstream branch
        try localRepository.branch.setUpstream(to: localRepository.branch.get(named: "origin/main"))

        // Check if the upstream branch is set
        let upstreamBranch = try XCTUnwrap(localRepository.branch.current.upstream as? Branch)
        XCTAssertEqual(upstreamBranch.target.id, try remoteRepository.HEAD.target.id)
        XCTAssertEqual(upstreamBranch.name, "origin/main")
        XCTAssertEqual(upstreamBranch.fullName, "refs/remotes/origin/main")
    }

    func testRepositoryFetch() async throws {
        // Create remote repository
        let remoteRepository = Repository.mock(named: "test-fetch--remote", in: Self.directory)

        // Create mock commit in the remote repository
        try remoteRepository.mockCommit()

        // Create local repository
        let localRepository = Repository.mock(named: "test-fetch--local", in: Self.directory)

        // Add remote repository to the local repository
        try localRepository.remote.add(named: "origin", at: remoteRepository.workingDirectory)

        // Fetch the commit from the remote repository
        try await localRepository.fetch()

        // Check if the remote branch is fetched
        let remoteBranch = try localRepository.branch.get(named: "origin/main")
        try XCTAssertEqual(remoteBranch.target.id, remoteRepository.HEAD.target.id)
    }
}
