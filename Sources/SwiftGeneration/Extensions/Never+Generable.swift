import Foundation

extension Never: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Never.self,
            description: "Never type (uninhabited)",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: [],
                debugDescription: "Cannot create an instance of Never"
            )
        )
    }

    public var generatedContent: GeneratedContent {
        fatalError("Never has no instances")
    }
}
