import Foundation

extension Float: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Float.self,
            description: "A floating-point number",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .number(let value):
            self = Float(value)
        case .string(let s):
            let text = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Float(text) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Float from string: \(s)"
                    )
                )
            }
            self = value
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Float from Kind: \(content.kind)"
                )
            )
        }
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .number(Double(self)))
    }
}
