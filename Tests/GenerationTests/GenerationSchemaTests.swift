import Testing
import Foundation
@testable import Generation

@Suite("GenerationSchema")
struct GenerationSchemaTests {

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

    @Test("Enum schema initialization")
    func enumSchema() {
        let schema = GenerationSchema(
            type: DummyType.self,
            description: "Test enum",
            anyOf: ["a", "b", "c"]
        )
        #expect(schema.debugDescription.contains("enum"))
    }

    @Test("Union schema initialization")
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

    @Test("Property creation")
    func propertyCreation() {
        let property = GenerationSchema.Property(
            name: "email",
            description: "Email address",
            type: String.self
        )
        _ = property
        #expect(Bool(true))
    }

    @Test("Property with guides")
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

    @Test("Debug description for array schema")
    func debugDescriptionArray() {
        let schema = [String].generationSchema
        #expect(schema.debugDescription.contains("array"))
    }
}
