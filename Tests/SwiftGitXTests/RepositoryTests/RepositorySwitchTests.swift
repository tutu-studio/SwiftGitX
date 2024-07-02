import SwiftGitX
import XCTest

final class RepositorySwitchTests: SwiftGitXTestCase {
    func testRepositorySwitchBranch() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-switch-branch", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new branch
        let branch = try repository.branch.create(named: "feature", target: commit)

        // Switch the new branch
        XCTAssertNoThrow(try repository.switch(to: branch))

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference
        XCTAssertEqual(head.name, branch.name)
        XCTAssertEqual(head.fullName, branch.fullName)
    }

    func testRepositorySwitchBranchGuess() async throws {
        let source = URL(string: "https://github.com/ibrahimcetin/PassbankMD.git")!
        let repositoryDirectory = Repository.mockDirectory(named: "test-switch-branch-guess", in: Self.directory)
        let repository = try await Repository.clone(from: source, to: repositoryDirectory)

        // Switch to the branch
        let remoteBranch = try repository.branch.get(named: "origin/fixes-for-kivymd-1.2")
        try repository.switch(to: remoteBranch)

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference
        XCTAssertEqual(head.name, remoteBranch.name.replacingOccurrences(of: "origin/", with: ""))
        XCTAssertEqual(head.target as? Commit, remoteBranch.target as? Commit)
    }

    func testRepositorySwitchCommit() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-switch-commit", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Switch to the commit
        XCTAssertNoThrow(try repository.switch(to: commit))

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference (detached HEAD)
        XCTAssertTrue(repository.isHEADDetached)

        XCTAssertEqual(head.name, "HEAD")
        XCTAssertEqual(head.fullName, "HEAD")
    }

    func testRepositorySwitchTagAnnotated() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-switch-tag-annotated", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new tag
        let tag = try repository.tag.create(named: "v1.0.0", target: commit)

        // Switch to the tag
        XCTAssertNoThrow(try repository.switch(to: tag))

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference
        XCTAssertEqual(head.name, tag.name)
        XCTAssertEqual(head.fullName, tag.fullName)
    }

    func testRepositorySwitchTagLightweight() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-switch-tag-lightweight", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new tag
        let tag = try repository.tag.create(named: "v1.0.0", target: commit, type: .lightweight)

        // When a lightweight tag is created, the tag ID is the same as the commit ID
        XCTAssertEqual(tag.id, commit.id)

        // Switch to the tag
        XCTAssertNoThrow(try repository.switch(to: tag))

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference
        XCTAssertEqual(head.target.id, tag.id)

        XCTAssertEqual(head.name, tag.name)
        XCTAssertEqual(head.fullName, tag.fullName)
    }

    func testRepositorySwitchTagLightweightTreeFailure() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-switch-tag-lightweight-tree-failure", in: Self.directory)

        // Create mock commit
        let commit = try repository.mockCommit()

        // Create a new tag
        let tag = try repository.tag.create(named: "v1.0.0", target: commit.tree, type: .lightweight)

        // Switch to the tag
        XCTAssertThrowsError(try repository.switch(to: tag))
    }

    // TODO: Add test for remote branch checkout
}
