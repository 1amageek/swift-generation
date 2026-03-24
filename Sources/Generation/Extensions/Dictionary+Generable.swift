import Foundation

// MARK: - Dictionary Generable Conformance

extension Dictionary: Generable where Key == String, Value: Generable {

    public static var generationSchema: GenerationSchema {
        // Create a dictionary schema with additionalProperties
        let valueSchema = Value.generationSchema.schemaType
        return GenerationSchema(
            schemaType: .dictionary(valueType: valueSchema),
            description: "Dictionary with String keys and \(String(describing: Value.self)) values"
        )
    }
}

// MARK: - Dictionary ConvertibleToGeneratedContent

extension Dictionary: ConvertibleToGeneratedContent where Key == String, Value: ConvertibleToGeneratedContent {
    public var generatedContent: GeneratedContent {
        var properties: [String: GeneratedContent] = [:]
        let orderedKeys = self.keys.sorted()

        for key in orderedKeys {
            if let value = self[key] {
                properties[key] = value.generatedContent
            }
        }

        return GeneratedContent(kind: .structure(properties: properties, orderedKeys: orderedKeys))
    }
}

// MARK: - Dictionary ConvertibleFromGeneratedContent

extension Dictionary: ConvertibleFromGeneratedContent where Key == String, Value: ConvertibleFromGeneratedContent {
    public init(_ content: GeneratedContent) throws {
        switch content.kind {
        case .structure(let properties, _):
            var dict: [String: Value] = [:]
            for (key, generatedContent) in properties {
                dict[key] = try Value(generatedContent)
            }
            self = dict
        case .string(let text):
            // Try to parse as JSON
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let data = trimmed.data(using: .utf8) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to convert string to data for JSON parsing"
                    )
                )
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: [],
                        debugDescription: "Unable to decode Dictionary from string: expected valid JSON object format"
                    )
                )
            }

            var dict: [String: Value] = [:]
            for (key, value) in json {
                if JSONSerialization.isValidJSONObject(value) {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
                    dict[key] = try Value(GeneratedContent(json: jsonString))
                } else {
                    // Primitive values (String, Number, Bool) are not valid
                    // top-level JSON objects; wrap them directly.
                    dict[key] = try Value(GeneratedContent(kind: .string("\(value)")))
                }
            }
            self = dict
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unable to decode Dictionary from Kind: \(content.kind)"
                )
            )
        }
    }
}
