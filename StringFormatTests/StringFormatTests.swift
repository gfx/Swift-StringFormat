//
//  StringFormatTests.swift
//  StringFormatTests
//
//  Created by Fuji foro on 2015/01/02.
//  Copyrifht (c) 2015年 FUJI foro. All rifhts reserved.
//

import UIKit
import XCTest
import StringFormat

class StringFormatTests: XCTestCase {

    func testBasicFormat() {
        XCTAssertEqual(format("<%s>", "foo"), "<foo>")
        XCTAssertEqual(format("<%d>", 100), "<100>")
        XCTAssertEqual(format("<%f>", 3.14), "<3.14>")
        XCTAssertEqual(format("<%%>"), "<%>")
    }

    func testString() {
        XCTAssertEqual(format("<%s>", nil as String?), "<(nil)>")
    }

    func testDecimal() {
        XCTAssertEqual(format("<%d>", 123),         "<123>")
        XCTAssertEqual(format("<%d>", 123.456),     "<123>")
        XCTAssertEqual(format("<%d>", UInt(123)),   "<123>")
        XCTAssertEqual(format("<%d>", Int8(123)),   "<123>")
        XCTAssertEqual(format("<%d>", UInt8(123)),  "<123>")
        XCTAssertEqual(format("<%d>", Int16(123)),  "<123>")
        XCTAssertEqual(format("<%d>", UInt16(123)), "<123>")
        XCTAssertEqual(format("<%d>", Int32(123)),  "<123>")
        XCTAssertEqual(format("<%d>", UInt32(123)), "<123>")
        XCTAssertEqual(format("<%d>", Int64(123)),  "<123>")
        XCTAssertEqual(format("<%d>", UInt64(123)), "<123>")
    }

    func testFloat() {
        XCTAssertEqual(format("<%f>", 123),     "<123>")
        XCTAssertEqual(format("<%f>", 123.456), "<123.456>")
    }

    func testArgmentsOrder() {
        XCTAssertEqual(format("<%s> <%s> <%s>", "a", "b", "c"), "<a> <b> <c>")
    }

    func testArgumentIndex() {
        XCTAssertEqual(format("<%1$s> <%2$s> <%3$s>", "a", "b", "c"), "<a> <b> <c>")
        XCTAssertEqual(format("<%3$s> <%1$s> <%2$s>", "a", "b", "c"), "<c> <a> <b>")

        XCTAssertEqual(format("<%3$s> <%1$s> <%2$s> <%10$s>", "a", "b", "c", nil, nil, nil, nil, nil, nil, "z"), "<c> <a> <b> <z>", "argument index >= 10")
    }

    func testArgumentIndexMixedInOrdered() {
        XCTAssertEqual(format("<%1$s> <%s> <%1$s> <%s>", "a", "b"), "<a> <a> <a> <b>")
        XCTAssertEqual(format("<%1$s> <%s> <%2$s> <%s>", "a", "b"), "<a> <a> <b> <b>")
    }

    func testMinWidthForString() {
        XCTAssertEqual(format("<%1s>", "foo"),  "<foo>")
        XCTAssertEqual(format("<%5s>", "foo"),  "<  foo>")
        XCTAssertEqual(format("<%10s>", "foo"), "<       foo>")
    }

    func testMinWidthForDecimal() {
        XCTAssertEqual(format("<%1d>", 123),  "<123>")
        XCTAssertEqual(format("<%5d>", 123),  "<  123>")
        XCTAssertEqual(format("<%10d>", 123), "<       123>")
    }

    func testMinWidthWithZeroForDecimal() {
        XCTAssertEqual(format("<%01d>", 123),  "<123>")
        XCTAssertEqual(format("<%05d>", 123),  "<00123>")
        XCTAssertEqual(format("<%010d>", 123), "<0000000123>")
    }

    func testMaxWidthForString() {
        XCTAssertEqual(format("<%.2s>", "foo"),  "<fo>")
        XCTAssertEqual(format("<%.5s>", "foo"),  "<foo>")
        XCTAssertEqual(format("<%.10s>", "foo bar baz"),  "<foo bar ba>")
    }

    func testLeftJustifyForString() {
        XCTAssertEqual(format("<%-1s>", "foo"),  "<foo>")
        XCTAssertEqual(format("<%-5s>", "foo"),  "<foo  >")
        XCTAssertEqual(format("<%-10s>", "foo"), "<foo       >")
    }

    func testLeftJustifyForDecimal() {
        XCTAssertEqual(format("<%-1d>", 123),  "<123>")
        XCTAssertEqual(format("<%-5d>", 123),  "<123  >")
        XCTAssertEqual(format("<%-10d>", 123), "<123       >")
    }

    func testSpacePrefixForDesimal() {
        XCTAssertEqual(format("<% d>", 123),    "< 123>")
        XCTAssertEqual(format("<% d>", -123),   "<-123>")

        XCTAssertEqual(format("<% 5d>", 123),   "<  123>")
        XCTAssertEqual(format("<% 10d>", 123),  "<       123>")
        XCTAssertEqual(format("<%- 5d>", 123),  "< 123 >")
        XCTAssertEqual(format("<%- 10d>", 123), "< 123      >")
    }

    func testPlusPrefixForDesimal() {
        XCTAssertEqual(format("<%+d>", 123),    "<+123>")
        XCTAssertEqual(format("<%+d>", -123),   "<-123>")

        XCTAssertEqual(format("<%+5d>", 123),   "< +123>")
        XCTAssertEqual(format("<%+10d>", 123),  "<      +123>")
        XCTAssertEqual(format("<%-+5d>", 123),  "<+123 >")
        XCTAssertEqual(format("<%-+10d>", 123), "<+123      >")
    }

    func testSpacePrefixForFloat() {
        XCTAssertEqual(format("<% f>", 1.23),    "< 1.23>")
        XCTAssertEqual(format("<% f>", -1.23),   "<-1.23>")

        XCTAssertEqual(format("<% 6f>", 1.23),   "<  1.23>")
        XCTAssertEqual(format("<% 10f>", 1.23),  "<      1.23>")
        XCTAssertEqual(format("<%- 6f>", 1.23),  "< 1.23 >")
        XCTAssertEqual(format("<%- 10f>", 1.23), "< 1.23     >")
    }

    func testPlusPrefixForFloat() {
        XCTAssertEqual(format("<%+f>", 1.23),    "<+1.23>")
        XCTAssertEqual(format("<%+f>", -1.23),   "<-1.23>")

        XCTAssertEqual(format("<%+6f>", 1.23),   "< +1.23>")
        XCTAssertEqual(format("<%+10f>", 1.23),  "<     +1.23>")
        XCTAssertEqual(format("<%-+6f>", 1.23),  "<+1.23 >")
        XCTAssertEqual(format("<%-+10f>", 1.23), "<+1.23     >")
    }

    func testPrecisionForFloat() {
        XCTAssertEqual(format("<%.1f>", Float32(123.456)), "<123.4>")
        XCTAssertEqual(format("<%.1f>", Float64(123.456)), "<123.4>")
        XCTAssertEqual(format("<%.1f>", Float80(123.456)), "<123.4>")

        XCTAssertEqual(format("<%.3f>", Float32(123.456)), "<123.456>")
        XCTAssertEqual(format("<%.3f>", Float64(123.456)), "<123.456>")
        XCTAssertEqual(format("<%.3f>", Float80(123.456)), "<123.456>")

        XCTAssertEqual(format("<%.5f>", Float32(123.456)), "<123.45600>")
        XCTAssertEqual(format("<%.5f>", Float64(123.456)), "<123.45600>")
        XCTAssertEqual(format("<%.5f>", Float80(123.456)), "<123.45600>")

        XCTAssertEqual(format("<%.1f>", Float32(-123.456)), "<-123.4>")
        XCTAssertEqual(format("<%.1f>", Float64(-123.456)), "<-123.4>")
        XCTAssertEqual(format("<%.1f>", Float80(-123.456)), "<-123.4>")

        XCTAssertEqual(format("<%.3f>", Float32(-123.456)), "<-123.456>")
        XCTAssertEqual(format("<%.3f>", Float64(-123.456)), "<-123.456>")
        XCTAssertEqual(format("<%.3f>", Float80(-123.456)), "<-123.456>")

        XCTAssertEqual(format("<%.5f>", Float32(-123.456)), "<-123.45600>")
        XCTAssertEqual(format("<%.5f>", Float64(-123.456)), "<-123.45600>")
        XCTAssertEqual(format("<%.5f>", Float80(-123.456)), "<-123.45600>")

    }
}
