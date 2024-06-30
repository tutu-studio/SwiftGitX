import SwiftGitX
import XCTest

final class RepositoryPropertyTests: SwiftGitXTestCase {
    func testRepositoryHEAD() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-head", in: Self.directory)

        // Commit the file
        try repository.mockCommit()

        // Get the HEAD reference
        let head = try repository.HEAD

        // Check the HEAD reference
        XCTAssertEqual(head.name, "main")
        XCTAssertEqual(head.fullName, "refs/heads/main")
    }

    func testRepositoryHEADUnborn() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-head-unborn", in: Self.directory)

        XCTAssertTrue(repository.isHEADUnborn)

        XCTAssertThrowsError(try repository.HEAD)
    }

    func testRepositoryWorkingDirectory() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-working-directory", in: Self.directory)

        // Get the working directory of the repository
        let repositoryWorkingDirectory = try XCTUnwrap(repository.workingDirectory)

        // Get the path of the mock repository directory
        let expectedDirectory = if Self.directory.isEmpty {
            URL.temporaryDirectory.appending(components: "SwiftGitXTests", "test-working-directory/")
        } else {
            URL.temporaryDirectory.appending(components: "SwiftGitXTests", Self.directory, "test-working-directory/")
        }

        // Check if the working directory is the same as the expected directory
        XCTAssertEqual(repositoryWorkingDirectory.resolvingSymlinksInPath(), expectedDirectory)
    }

    func testRepositoryIsEmpty() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-is-empty", in: Self.directory)

        // Check if the repository is empty
        XCTAssertTrue(repository.isEmpty)

        // Create a commit
        _ = try repository.mockCommit()

        // Check if the repository is not empty
        XCTAssertFalse(repository.isEmpty)
    }
}
