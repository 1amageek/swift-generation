import Foundation

// MARK: - Optional Generable Conformance

extension Optional: Generable where Wrapped: Generable {
    public typealias PartiallyGenerated = Wrapped.PartiallyGenerated

    public static var generationSchema: GenerationSchema {
        // Return the wrapped type's schema directly
        // The Optional handling will be done at the PropertyInfo level
        return Wrapped.generationSchema
    }

    public func asPartiallyGenerated() -> PartiallyGenerated {
        switch self {
        case .none:
            fatalError("Cannot convert nil to PartiallyGenerated")
        case .some(let wrapped):
            return wrapped.asPartiallyGenerated()
        }
    }
}

// MARK: - ConvertibleFromGeneratedContent

extension Optional: ConvertibleFromGeneratedContent where Wrapped: ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .null:
            self = .none
        default:
            self = .some(try Wrapped(content))
        }
    }
}

// MARK: - ConvertibleToGeneratedContent

extension Optional: ConvertibleToGeneratedContent where Wrapped: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        switch self {
        case .none:
            return GeneratedContent(kind: .null)
        case .some(let wrapped):
            return wrapped.generatedContent
        }
    }
}
