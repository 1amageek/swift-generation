import Foundation

extension Double: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Double.self,
            description: "A double-precision floating-point number",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .number(let value):
            self = value
        case .string(let s):
            let text = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Double(text) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Double from string: \(s)"
                    )
                )
            }
            self = value
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Double from Kind: \(content.kind)"
                )
            )
        }
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .number(self))
    }
}
