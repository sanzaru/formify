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
