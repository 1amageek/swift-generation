import Foundation

extension String: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: String.self,
            description: "Text content",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        self = content.text
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .string(self))
    }
}
