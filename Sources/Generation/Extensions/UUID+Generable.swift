import Foundation

extension UUID: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: UUID.self,
            description: "A universally unique identifier in standard UUID format (8-4-4-4-12)",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        let text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let uuid = UUID(uuidString: text) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid UUID format: '\(text)'. Expected format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                )
            )
        }
        self = uuid
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .string(self.uuidString))
    }
}
