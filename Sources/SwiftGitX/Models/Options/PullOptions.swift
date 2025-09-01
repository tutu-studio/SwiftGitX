import Foundation

/// Strategy used by `pull` to integrate fetched changes.
public enum PullStrategy: Sendable {
    /// Fast-forward only; if not possible, throw.
    case fastForward
    /// Perform a merge when fast-forward is not possible. (Not yet implemented.)
    case merge
    /// Rebase the current branch onto upstream. (Not yet implemented.)
    case rebase
}

/// Options for the pull operation.
public struct PullOptions: Sendable {
    /// The strategy to integrate upstream. Default is `.fastForward`.
    public let strategy: PullStrategy

    public init(strategy: PullStrategy = .fastForward) {
        self.strategy = strategy
    }

    public static let `default` = PullOptions()
}

