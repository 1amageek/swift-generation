import Foundation

extension URL: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: URL.self,
            description: "A uniform resource locator (URL)",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        let text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: text) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Invalid URL format: '\(text)'"
                )
            )
        }
        self = url
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .string(self.absoluteString))
    }
}
