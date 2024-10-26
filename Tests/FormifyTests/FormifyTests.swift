import Testing
@testable import Formify

@Test func testValidation() async throws {
    var field = FormifyField("", operators: [.pattern("[a-z]+")])
    #expect(field.value.isEmpty)

    field.value = "ABC"
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 3)

    #expect(field.errors.contains(FormifyError.pattern))

    field.value = "abc"
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 3)

    #expect(field.isValid)
}

@Test func testRequired() async throws {
    var field = FormifyField("", operators: [.required])

    #expect(!field.isValid)
    #expect(!field.isTouched)

    field.value = "ABC"
    field.value = ""

    #expect(field.value.isEmpty)
    #expect(field.errors.first == .required)

    field.value = "ABC"
    #expect(field.isValid)
}

@Test func testMinLength() async throws {
    var field = FormifyField("", operators: [.required, .minLength(10)])
    #expect(field.value.isEmpty)

    field.value = "ABC"
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 3)

    if case .minLength(let minLength) = field.errors.first {
        #expect(minLength == field.value.count)
        #expect(!field.isValid)
    } else {
        fatalError("Min length error not found")
    }

    field.value = "ABCDEFGHIJ"
    #expect(field.isValid)
}

@Test func testMaxLength() async throws {
    var field = FormifyField("", operators: [.required, .maxLength(3)])
    #expect(field.value.isEmpty)

    field.value = "ABC4"
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 4)

    if case .maxLength(let maxLength) = field.errors.first {
        #expect(maxLength == field.value.count)
        #expect(!field.isValid)
    } else {
        fatalError("Max length error not found")
    }

    field.value = "ABC"
    #expect(field.isValid)
}

@Test func testTrimming() async throws {
    var field = FormifyField("", operators: [.required, .maxLength(3)])
    #expect(field.value.isEmpty)

    field.value = "ABCD   "
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 4)
}

@Test func testURLWithScheme() async throws {
    var field = FormifyField("https://example.com", operators: [.urlWithScheme])
    #expect(!field.value.isEmpty)
    #expect(field.isValid)

    field.value = "https://example.com?foo=bar&foo2=bar2"
    #expect(field.isValid)

    field.value = "https://example.com/somepath/?foo=bar&foo2=bar2"
    #expect(field.isValid)

    field.value = "ssh://localhost"
    #expect(field.isValid)

    field.value = "foobar"
    #expect(!field.isValid)
}

@Test func testURLNoScheme() async throws {
    var field = FormifyField("localhost", operators: [.urlNoScheme])
    #expect(!field.value.isEmpty)
    #expect(field.isValid)

    field.value = "example.com"
    #expect(field.isValid)

    field.value = "https://example.com"
    #expect(!field.isValid)

    field.value = "()()()@@@@@´´´´´````)"
    #expect(!field.isValid)
}

@Test func testCustomHandler() async throws {
    var field = FormifyField("Some Value", operators: [.custom({ $0 == "Foo" })])
    #expect(!field.value.isEmpty)

    #expect(!field.isValid)

    field.value = "Foo"
    #expect(field.isValid)
}