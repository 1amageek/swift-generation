import Foundation

extension Int: Generable {
    public static var generationSchema: GenerationSchema {
        return GenerationSchema(
            type: Int.self,
            description: "An integer value",
            properties: []
        )
    }

    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .number(let value):
            guard value.truncatingRemainder(dividingBy: 1) == 0 else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Cannot convert decimal number \(value) to Int"
                    )
                )
            }
            self = Int(value)
        case .string(let s):
            let text = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value = Int(text) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Int from string: \(s)"
                    )
                )
            }
            self = value
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Int from Kind: \(content.kind)"
                )
            )
        }
    }

    public var generatedContent: GeneratedContent {
        return GeneratedContent(kind: .number(Double(self)))
    }
}
