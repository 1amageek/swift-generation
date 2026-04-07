import Foundation

public protocol Tool<Arguments, Output>: Sendable {
    associatedtype Output: PromptRepresentable

    associatedtype Arguments: ConvertibleFromGeneratedContent

    var name: String { get }

    var description: String { get }

    var includesSchemaInInstructions: Bool { get }

    var parameters: GenerationSchema { get }

    @concurrent func call(arguments: Arguments) async throws -> Output
}

extension Tool {
    public var name: String {
        return String(describing: type(of: self))
    }

    public var includesSchemaInInstructions: Bool {
        return true
    }
}

extension Tool where Self.Arguments: Generable {
    public var parameters: GenerationSchema {
        return Arguments.generationSchema
    }
}

extension Tool where Self.Arguments == String {
    @available(*, unavailable, message: "'Tool' that uses 'String' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}

extension Tool where Self.Arguments == Int {
    @available(*, unavailable, message: "'Tool' that uses 'Int' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}

extension Tool where Self.Arguments == Double {
    @available(*, unavailable, message: "'Tool' that uses 'Double' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}

extension Tool where Self.Arguments == Float {
    @available(*, unavailable, message: "'Tool' that uses 'Float' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}

extension Tool where Self.Arguments == Decimal {
    @available(*, unavailable, message: "'Tool' that uses 'Decimal' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}

extension Tool where Self.Arguments == Bool {
    @available(*, unavailable, message: "'Tool' that uses 'Bool' as 'Arguments' type is unsupported. Use '@Generable' struct instead.")
    public var parameters: GenerationSchema {
        fatalError()
    }
}
