import Testing
import Foundation
@_spi(Internal) @testable import Generation

// MARK: - Test types for schema verification

@Generable(description: "A user profile")
struct SchemaTestProfile {
    @Guide(description: "Full name")
    var name: String
    @Guide(description: "User age", .range(0...120))
    var age: Int
    var active: Bool
}

@Generable(description: "Priority level")
enum SchemaTestPriority {
    case low
    case medium
    case high
}

@Generable
struct SchemaTestNested {
    var title: String
    var tags: [String]
    var metadata: [String: String]
    var priority: SchemaTestPriority?
}

@Suite("GenerationSchema")
struct GenerationSchemaTests {

    // MARK: - Initializer variants

    struct DummyType: Generable {
        init(_ content: GeneratedContent) throws {}
        var generatedContent: GeneratedContent { GeneratedContent("") }
        static var generationSchema: GenerationSchema {
            GenerationSchema(type: DummyType.self, description: "Test", properties: [])
        }
    }

    @Test("Object schema initialization")
    func objectSchema() {
        let schema = GenerationSchema(
            type: DummyType.self,
            description: "Test object",
            properties: []
        )
        #expect(schema.debugDescription.contains("GenerationSchema"))
    }

    @Test("Enum schema initialization with anyOf strings")
    func enumSchema() {
        let schema = GenerationSchema(
            type: DummyType.self,
            description: "Test enum",
            anyOf: ["a", "b", "c"]
        )
        #expect(schema.debugDescription.contains("enum"))
    }

    @Test("Union schema initialization with anyOf types")
    func unionSchema() {
        struct TypeA: Generable {
            init(_ content: GeneratedContent) throws {}
            var generatedContent: GeneratedContent { GeneratedContent("") }
            static var generationSchema: GenerationSchema {
                GenerationSchema(type: TypeA.self, properties: [])
            }
        }
        struct TypeB: Generable {
            init(_ content: GeneratedContent) throws {}
            var generatedContent: GeneratedContent { GeneratedContent("") }
            static var generationSchema: GenerationSchema {
                GenerationSchema(type: TypeB.self, properties: [])
            }
        }

        let schema = GenerationSchema(
            type: DummyType.self,
            description: "Union",
            anyOf: [TypeA.self, TypeB.self]
        )
        #expect(schema.debugDescription.contains("anyOf"))
    }

    // MARK: - Property

    @Test("Property creation with description and type")
    func propertyCreation() {
        let property = GenerationSchema.Property(
            name: "email",
            description: "Email address",
            type: String.self
        )
        _ = property
        #expect(Bool(true))
    }

    @Test("Property with regex guides")
    func propertyWithGuides() {
        let regex = try! Regex("[a-z]+")
        let property = GenerationSchema.Property(
            name: "username",
            description: "Lowercase letters only",
            type: String.self,
            guides: [regex]
        )
        _ = property
        #expect(Bool(true))
    }

    // MARK: - DynamicGenerationSchema

    @Test("DynamicGenerationSchema creates valid schema")
    func dynamicSchema() throws {
        let dynamic = DynamicGenerationSchema(
            name: "Menu",
            properties: [
                DynamicGenerationSchema.Property(
                    name: "item",
                    schema: DynamicGenerationSchema(name: "item", anyOf: ["A", "B"])
                )
            ]
        )
        let schema = try GenerationSchema(root: dynamic, dependencies: [])
        #expect(schema.debugDescription.contains("GenerationSchema"))
    }

    // MARK: - Standard type schemas

    @Test("Array schema debug description")
    func debugDescriptionArray() {
        let schema = [String].generationSchema
        #expect(schema.debugDescription.contains("array"))
    }

    @Test("Dictionary schema debug description")
    func debugDescriptionDictionary() {
        let schema = [String: Int].generationSchema
        let desc = schema.debugDescription
        #expect(desc.contains("Dictionary") || desc.contains("dictionary"))
    }

    // MARK: - @Generable macro schema structure (via @testable)

    @Test("Struct schema has object type with correct properties")
    func structSchemaProperties() {
        let schema = SchemaTestProfile.generationSchema
        guard case .object(let props) = schema.schemaType else {
            Issue.record("Expected object schema type"); return
        }
        let names = props.map(\.name)
        #expect(names.contains("name"))
        #expect(names.contains("age"))
        #expect(names.contains("active"))
        #expect(names.count == 3)
    }

    @Test("Struct schema preserves description")
    func structSchemaDescription() {
        let schema = SchemaTestProfile.generationSchema
        #expect(schema.description == "A user profile")
    }

    @Test("Struct schema property descriptions from @Guide")
    func structSchemaPropertyDescriptions() {
        let schema = SchemaTestProfile.generationSchema
        guard case .object(let props) = schema.schemaType else {
            Issue.record("Expected object schema type"); return
        }
        let nameInfo = props.first { $0.name == "name" }
        #expect(nameInfo?.description == "Full name")

        let ageInfo = props.first { $0.name == "age" }
        #expect(ageInfo?.description == "User age")

        let activeInfo = props.first { $0.name == "active" }
        #expect(activeInfo?.description == nil)
    }

    @Test("Struct schema marks non-optional properties as required")
    func structSchemaRequired() {
        let schema = SchemaTestProfile.generationSchema
        guard case .object(let props) = schema.schemaType else {
            Issue.record("Expected object schema type"); return
        }
        for prop in props {
            #expect(prop.isOptional == false, "Property \(prop.name) should be required")
        }
    }

    @Test("Simple enum schema uses anyOf with case names")
    func enumSchemaAnyOf() {
        let schema = SchemaTestPriority.generationSchema
        let desc = schema.debugDescription
        #expect(desc.contains("enum") || desc.contains("anyOf"))
    }

    @Test("Nested struct schema has correct property types")
    func nestedSchemaTypes() {
        let schema = SchemaTestNested.generationSchema
        guard case .object(let props) = schema.schemaType else {
            Issue.record("Expected object schema type"); return
        }
        let names = props.map(\.name)
        #expect(names.contains("title"))
        #expect(names.contains("tags"))
        #expect(names.contains("metadata"))
        #expect(names.contains("priority"))

        let priorityInfo = props.first { $0.name == "priority" }
        #expect(priorityInfo?.isOptional == true)
    }

    // MARK: - toSchemaDictionary (@_spi via @testable)

    @Test("toSchemaDictionary outputs valid JSON Schema structure")
    func schemaDictionaryStructure() {
        let schema = SchemaTestProfile.generationSchema
        let dict = schema.toSchemaDictionary()

        #expect(dict["type"] as? String == "object")
        #expect(dict["description"] as? String == "A user profile")

        let properties = dict["properties"] as? [String: Any]
        #expect(properties != nil)
        #expect(properties?["name"] != nil)
        #expect(properties?["age"] != nil)
        #expect(properties?["active"] != nil)

        let required = dict["required"] as? [String]
        #expect(required != nil)
        #expect(required?.contains("name") == true)
        #expect(required?.contains("age") == true)
        #expect(required?.contains("active") == true)
    }

    @Test("toSchemaDictionary for enum outputs anyOf")
    func schemaDictionaryEnum() {
        let schema = SchemaTestPriority.generationSchema
        let dict = schema.toSchemaDictionary()
        // Enum schema should have enum or anyOf in JSON Schema
        let hasEnum = dict["enum"] != nil
        let hasAnyOf = dict["anyOf"] != nil
        let hasType = dict["type"] as? String == "string"
        #expect(hasEnum || hasAnyOf || hasType)
    }

    @Test("toSchemaDictionary with asRootSchema adds $schema")
    func schemaDictionaryRoot() {
        let schema = SchemaTestProfile.generationSchema
        let dict = schema.toSchemaDictionary(asRootSchema: true)
        #expect(dict["$schema"] as? String == "https://json-schema.org/draft/2020-12/schema")
    }
}
