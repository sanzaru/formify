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

@Test func testTouched() async throws {
    var field = FormifyField("", operators: [.pattern("[a-z]+")])
    #expect(field.value.isEmpty)
    #expect(!field.isTouched)

    field.value = "ABC"
    #expect(!field.value.isEmpty)
    #expect(field.value.count == 3)
    #expect(field.isTouched)
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

@Test func nonRequired() async throws {
    var field = FormifyField("", operators: [.pattern("[a-z]+")])

    #expect(field.value.isEmpty)
    #expect(field.isValid)
    #expect(field.errors.isEmpty)
    #expect(!field.isTouched)
    #expect(!field.isRequired)

    // Write something to the field
    field.value = "abc"
    #expect(!field.value.isEmpty)

    // Empty the field
    field.value = ""
    #expect(field.errors.isEmpty)
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

    field.value = "https://an-url.with.some.domain.entries/and/some/path-example"
    #expect(field.isValid)

    field.value = "https://an-url.with.some.domain.entries/and/some/path-example?foo=bar&foo2=bar2"
    #expect(field.isValid)

    field.value = "https://an-url.with.some.domain.entries/and/some/path-example/?foo=bar&foo2=bar2#foo"
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

@Test func testEmailOperator() async throws {
    var field = FormifyField("", operators: [.email])
    // Invalid email
    field.value = "notanemail"
    #expect(!field.isValid)
    // Valid email
    field.value = "foo@bar.com"
    #expect(field.isValid)
}

@Test func testPhoneOperator() async throws {
    var field = FormifyField("", operators: [.phonenumber])
    // Invalid phone
    field.value = "abcdefg"
    #expect(!field.isValid)
    // Valid phone (simple check, as per default pattern)
    field.value = "+1-202-555-0173"
    #expect(field.isValid)
}

@Test func testDisableTrimmingOperator() async throws {
    var field = FormifyField("   value   ", operators: [.disableTrimming])
    // Should not trim, so value remains with whitespace
    #expect(field.value == "   value   ")
    // Update value and check again
    field.value = "  abc  "
    #expect(field.value == "  abc  ")
}

@Test func testCollectionIsValid() async throws {
    let field1 = FormifyField("abc", operators: [.required, .minLength(2)])
    let field2 = FormifyField("", operators: [.pattern("[a-z]+")])
    let field3 = FormifyField("foobar", operators: [.required])
    let fields = [field1, field2, field3]
    // All valid except field2, which is empty but not required
    #expect(!fields.isValid)
    // Now, make a required field invalid
    let invalidFields = [field1, field2, FormifyField("", operators: [.required])]
    #expect(!invalidFields.isValid)
}

@Test func testInitWithNonEmptyValue() async throws {
    var field = FormifyField("preset", operators: [.minLength(3)])
    #expect(field.isTouched)
    #expect(field.errors.isEmpty)
    // If minLength is higher than the value, should error
    field = FormifyField("short", operators: [.minLength(10)])
    #expect(!field.errors.isEmpty)
    #expect(!field.isValid)
}
