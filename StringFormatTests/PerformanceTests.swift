//
//  PerformanceTests.swift
//  StringFormat
//
//  Created by Fuji Goro on 2015/01/02.
//  Copyright (c) 2015年 FUJI Goro. All rights reserved.
//

import Foundation
import XCTest
import StringFormat


class PerformanceTests: XCTestCase {
    func testStrings() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(format("<%s> <%s> <%s> <%s>", "aaa", "bbb", "ccc", "ddd"), "<aaa> <bbb> <ccc> <ddd>")
            }
        }
    }

    func testIntegers() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(format("<%d> <%d> <%d> <%d>", 100, 200, 300, 400), "<100> <200> <300> <400>")
            }
        }
    }

    func testFloats() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(format("<%.2f> <%.2f> <%.2f> <%.2f>", 3.14, 3.14, 3.14, 3.14), "<3.14> <3.14> <3.14> <3.14>")
            }
        }
    }

    func testStringsWithNSStringFormat() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(NSString(format:"<%@> <%@> <%@> <%@>", "aaa", "bbb", "ccc", "ddd"), "<aaa> <bbb> <ccc> <ddd>")
            }
        }
    }
    func testIntegersWithNSStringFormat() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(NSString(format:"<%d> <%d> <%d> <%d>", 100, 200, 300, 400), "<100> <200> <300> <400>")
            }
        }
    }

    func testDoublesWithNSStringFormat() {
        self.measureBlock() {
            for _ in 1 ... 100 {
                XCTAssertEqual(NSString(format:"<%.2f> <%.2f> <%.2f> <%.2f>", 3.14, 3.14, 3.14, 3.14), "<3.14> <3.14> <3.14> <3.14>")
            }
        }
    }

}