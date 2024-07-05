import SwiftGitX
import XCTest

final class RepositoryDiffTests: SwiftGitXTestCase {
    /// This test creates a commit and a working tree change (there is no staged change).
    func testDiffHEADToWorkingTree() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-head-working-tree", in: Self.directory)

        // Create a commit
        let file = try repository.mockFile(named: "README.md", content: "The commit content!\n")
        try repository.mockCommit(file: file)

        // Update the file content
        try Data("The working tree content!\n".utf8).write(to: file)

        // Get the diff between HEAD and the working tree
        let diff = try repository.diff()

        // Check if the diff count is correct
        XCTAssertEqual(diff.patches[0].hunks.count, 1)

        let hunk = diff.patches[0].hunks[0]

        // Check the hunk lines
        XCTAssertEqual(hunk.lines.count, 2)
        XCTAssertEqual(hunk.lines[0].type, .deletion)
        XCTAssertEqual(hunk.lines[0].content, "The commit content!\n")

        XCTAssertEqual(hunk.lines[1].type, .addition)
        XCTAssertEqual(hunk.lines[1].content, "The working tree content!\n")
    }

    /// This func creates base state for `testDiffHEADToWorkingTree_Staged`, `testDiffHEADToIndex` and
    /// `testDiffHEADToWorkingTreeWithIndex`. It creates a commit, a staged change and a working tree change.
    func createBaseStateForDiffHEAD(_ repository: Repository) throws {
        // Create a file
        let file = try repository.mockFile(named: "README.md", content: "The commit content!\n")

        // Create a commit
        try repository.mockCommit(file: file)

        // Update the file content and add the file
        try Data("The index content!\n".utf8).write(to: file)
        try repository.add(file: file)

        // Update the file content
        try Data("\nThe working tree content!\n".utf8).write(to: file)
    }

    /// This test creates a commit, a staged change and a working tree change.
    /// This test should compare the staged change with the working tree change.
    func testDiffHEADToWorkingTree_Staged() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-head-working-tree_staged", in: Self.directory)

        // Create a base state for the test
        try createBaseStateForDiffHEAD(repository)

        // Get the diff between HEAD and the working tree
        let diff = try repository.diff()

        // Check if the diff count is correct
        XCTAssertEqual(diff.patches[0].hunks.count, 1)

        let hunk = diff.patches[0].hunks[0]

        // Check the hunk lines
        XCTAssertEqual(hunk.lines.count, 3)
        XCTAssertEqual(hunk.lines[0].type, .deletion)
        XCTAssertEqual(hunk.lines[0].content, "The index content!\n")

        XCTAssertEqual(hunk.lines[1].content, "\n")

        XCTAssertEqual(hunk.lines[2].type, .addition)
        XCTAssertEqual(hunk.lines[2].content, "The working tree content!\n")
    }

    func testDiffHEADToIndex() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-head-index", in: Self.directory)

        // Create a base state for the test
        try createBaseStateForDiffHEAD(repository)

        // Get the diff between HEAD and the index
        let diff = try repository.diff(to: .index)

        // Check if the diff count is correct
        XCTAssertEqual(diff.patches[0].hunks.count, 1)

        let hunk = diff.patches[0].hunks[0]

        // Check the hunk lines
        XCTAssertEqual(hunk.lines.count, 2)
        XCTAssertEqual(hunk.lines[0].type, .deletion)
        XCTAssertEqual(hunk.lines[0].content, "The commit content!\n")

        XCTAssertEqual(hunk.lines[1].type, .addition)
        XCTAssertEqual(hunk.lines[1].content, "The index content!\n")
    }

    // This method tests the created diff if the repository has a staged change and a working tree change.
    // The staged change should be included in the diff.
    func testDiffHEADToWorkingTreeWithIndex() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-head-working-tree-index", in: Self.directory)

        // Create a base state for the test
        try createBaseStateForDiffHEAD(repository)

        // Get the diff between HEAD and the working tree with index
        let diff = try repository.diff(to: [.index, .workingTree])

        // Check if the diff count is correct
        XCTAssertEqual(diff.patches[0].hunks.count, 1)

        let hunk = diff.patches[0].hunks[0]

        // Check the hunk lines
        XCTAssertEqual(hunk.lines.count, 3)
        XCTAssertEqual(hunk.lines[0].type, .deletion)
        XCTAssertEqual(hunk.lines[0].content, "The commit content!\n")

        XCTAssertEqual(hunk.lines[1].content, "\n")

        XCTAssertEqual(hunk.lines[2].type, .addition)
        XCTAssertEqual(hunk.lines[2].content, "The working tree content!\n")
    }

    /// This method creates two commits in the repository and returns them.
    private func mockCommits(repository: Repository) throws -> (initialCommit: Commit, secondCommit: Commit) {
        let file = try repository.mockFile(named: "README.md", content: "Hello, SwiftGitX!\n")

        // Commit the changes
        let initialCommit = try repository.mockCommit(message: "Initial commit", file: file)

        // Modify the file
        try Data("Hello, World!\n".utf8).write(to: file)

        // Commit the changes
        let secondCommit = try repository.mockCommit(message: "Second commit", file: file)

        return (initialCommit, secondCommit)
    }

    func testDiffBetweenCommitAndCommit() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-commit", in: Self.directory)

        // Create commits
        let (initialCommit, secondCommit) = try mockCommits(repository: repository)

        // Get the diff between the two commits
        let diff = try repository.diff(from: initialCommit, to: secondCommit)

        // Check if the diff count is correct
        XCTAssertEqual(diff.changes.count, 1)

        // Get the change
        let change = try XCTUnwrap(diff.changes.first)

        // Check the change
        XCTAssertEqual(change.oldFile.path, "README.md")
        XCTAssertEqual(change.newFile.path, "README.md")
        XCTAssertEqual(change.type, .modified)

        // Get the blob of the new file
        let newBlob: Blob = try repository.show(id: change.newFile.id)

        // Check the blob content
        let newContent = try XCTUnwrap(String(data: newBlob.content, encoding: .utf8))
        XCTAssertEqual(newContent, "Hello, World!\n")
    }

    func testDiffBetweenTreeAndTree() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-tree", in: Self.directory)

        // Create commits
        let (initialCommit, secondCommit) = try mockCommits(repository: repository)

        // Get the diff between the two commits
        let diff = try repository.diff(from: initialCommit.tree, to: secondCommit.tree)

        // Check if the diff count is correct
        XCTAssertEqual(diff.changes.count, 1)

        // Get the change
        let change = try XCTUnwrap(diff.changes.first)

        // Check the change
        XCTAssertEqual(change.oldFile.path, "README.md")
        XCTAssertEqual(change.newFile.path, "README.md")
        XCTAssertEqual(change.type, .modified)

        // Get the blob of the new file
        let newBlob: Blob = try repository.show(id: change.newFile.id)

        // Check the blob content
        let newContent = try XCTUnwrap(String(data: newBlob.content, encoding: .utf8))
        XCTAssertEqual(newContent, "Hello, World!\n")
    }

    func testDiffBetweenTagAndTag() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-tag", in: Self.directory)

        // Create commits
        let (initialCommit, secondCommit) = try mockCommits(repository: repository)

        // Create a tag for the initial commit
        let initialTag = try repository.tag.create(named: "initial-tag", target: initialCommit)

        // Create a tag for the second commit
        let secondTag = try repository.tag.create(named: "second-tag", target: secondCommit)

        // Get the diff between the two commits
        let diff = try repository.diff(from: initialTag, to: secondTag)

        // Check if the diff count is correct
        XCTAssertEqual(diff.changes.count, 1)

        // Get the change
        let change = try XCTUnwrap(diff.changes.first)

        // Check the change
        XCTAssertEqual(change.oldFile.path, "README.md")
        XCTAssertEqual(change.newFile.path, "README.md")
        XCTAssertEqual(change.type, .modified)

        // Get the blob of the new file
        let newBlob: Blob = try repository.show(id: change.newFile.id)

        // Check the blob content
        let newContent = try XCTUnwrap(String(data: newBlob.content, encoding: .utf8))
        XCTAssertEqual(newContent, "Hello, World!\n")
    }

    func testDiffCommitParent() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-commit-parent", in: Self.directory)

        // Create commits
        _ = try mockCommits(repository: repository)

        // Remove old content and write new content than commit
        let headCommit = try repository.mockCommit(
            message: "Third commit",
            file: repository.mockFile(named: "README.md", content: "Merhaba, Dünya!")
        )

        // Get the diff between the latest commit and its parent
        let diff = try repository.diff(commit: headCommit)

        // Check if the diff count is correct
        XCTAssertEqual(diff.changes.count, 1)

        // Get the change
        let change = try XCTUnwrap(diff.changes.first)

        // Check the change
        XCTAssertEqual(change.type, .modified)
        XCTAssertEqual(change.oldFile.path, "README.md")
        XCTAssertEqual(change.newFile.path, "README.md")

        // Get the blob of the new file
        let newBlob: Blob = try repository.show(id: change.newFile.id)
        let newText = try XCTUnwrap(String(data: newBlob.content, encoding: .utf8))

        // Get the blob of the old file
        let oldBlob: Blob = try repository.show(id: change.oldFile.id)
        let oldText = try XCTUnwrap(String(data: oldBlob.content, encoding: .utf8))

        // Check the blob content and size
        XCTAssertEqual(newText, "Merhaba, Dünya!")
        XCTAssertEqual(oldText, "Hello, World!\n")
    }

    func testDiffCommitNoParent() throws {
        // Create a mock repository at the temporary directory
        let repository = Repository.mock(named: "test-diff-commit-no-parent", in: Self.directory)

        // Create a commit
        let commit = try repository.mockCommit()

        // Get the diff between the commit and its parent
        let diff = try repository.diff(commit: commit)

        // Check if the diff count is correct
        XCTAssertEqual(diff.changes.count, 0)
    }

    func testRepositoryStatusUntracked() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-status-untracked", in: Self.directory)

        // Create a new file in the repository
        _ = try repository.mockFile(named: "README.md", content: "Hello, World!")

        // Get the status of the repository
        let status = try repository.status()

        // Check the status of the repository
        XCTAssertEqual(status.count, 1)

        // Get the status entry
        let statusEntry = try XCTUnwrap(status.first)

        // Check the status entry properties
        XCTAssertEqual(statusEntry.status, .workingTreeNew)
        XCTAssertNil(statusEntry.index) // There is no index changes

        // Get working tree changes
        let workingTreeChanges = try XCTUnwrap(statusEntry.workingTree)

        // Check the status entry diff delta properties
        XCTAssertEqual(workingTreeChanges.type, .untracked)

        XCTAssertEqual(workingTreeChanges.newFile.path, "README.md")
        XCTAssertEqual(workingTreeChanges.oldFile.path, "README.md")

        XCTAssertEqual(workingTreeChanges.newFile.size, "Hello, World!".count)
        XCTAssertEqual(workingTreeChanges.oldFile.size, 0)
    }

    func testRepositoryStatusAdded() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-status-added", in: Self.directory)

        // Create a new file in the repository
        let file = try repository.mockFile(named: "README.md", content: "Hello, World!")

        // Add the file
        try repository.add(path: file.lastPathComponent)

        // Get the status of the repository
        let status = try repository.status()

        // Check the status of the repository
        XCTAssertEqual(status.count, 1)

        // Get the status entry
        let statusEntry = try XCTUnwrap(status.first)

        // Check the status entry properties
        XCTAssertEqual(statusEntry.status, .indexNew)
        XCTAssertNil(statusEntry.workingTree) // There is no working tree changes
        let statusEntryDiffDelta = try XCTUnwrap(statusEntry.index)

        // Check the status entry diff delta properties
        XCTAssertEqual(statusEntryDiffDelta.type, .added)

        XCTAssertEqual(statusEntryDiffDelta.newFile.path, "README.md")
        XCTAssertEqual(statusEntryDiffDelta.oldFile.path, "README.md")

        XCTAssertEqual(statusEntryDiffDelta.newFile.size, "Hello, World!".count)
        XCTAssertEqual(statusEntryDiffDelta.oldFile.size, 0)

        // Get the blob of the new file
        let blob: Blob = try repository.show(id: statusEntryDiffDelta.newFile.id)
        let blobText = try XCTUnwrap(String(data: blob.content, encoding: .utf8))
        XCTAssertEqual(blobText, "Hello, World!")
    }

    func testRepositoryStatusFile_NewAndModified() throws {
        // Create a new repository at the temporary directory
        let repository = Repository.mock(named: "test-status-new-and-modified", in: Self.directory)

        // Create a new file in the repository
        let file = try repository.mockFile(named: "README.md", content: "Hello, World!")

        // Add the file
        try repository.add(file: file)

        // Modify the file
        try Data("Merhaba, Dünya!".utf8).write(to: file)

        // Get the status of the repository
        let status: [StatusEntry.Status] = try repository.status(file: file)

        // Check the status of the repository
        XCTAssertEqual(status.count, 2)

        // Check the status entry properties
        XCTAssertEqual(Set(status), Set([.indexNew, .workingTreeModified]))
    }

    func testDiffEquality() throws {
        // Create a repository at the directory
        let repository = Repository.mock(named: "test-diff-equality", in: Self.directory)

        // Create mock commits
        let (initialCommit, secondCommit) = try mockCommits(repository: repository)

        // Get the diff between the two commits
        let diff = try repository.diff(from: initialCommit, to: secondCommit)

        // Open second repository at the same directory
        let sameRepository = try Repository.open(at: repository.workingDirectory)

        // Get the diff between the two commits
        let sameDiff = try sameRepository.diff(from: initialCommit, to: secondCommit)

        // Check the diff properties are equal between the two repositories
        XCTAssertEqual(sameDiff, diff)
    }
}
