//
//  StringFormat.swift
//  StringFormat
//
//  Created by Fuji Goro on 2015/01/02.
//  Copyright (c) 2015年 FUJI Goro. All rights reserved.
//


import func Darwin.atof
import func Darwin.atoll
import func Darwin.pow

struct FormatAttribute {
    let argIndex: Int?
    let flags: UInt // bit vector
    let minWidth: Int
    let precisionOrMaxWidth: Int


    var hasSpacePrefixFlag: Bool {
        return flags & FillingFlag.SPACE_PREFIX.rawValue != 0
    }

    var hasPlusPrefixFlag: Bool {
        return flags & FillingFlag.PLUS_PREFIX.rawValue != 0
    }

    var hasLeftJustifyFlag: Bool {
        return flags & FillingFlag.LEFT_JUSTIFY.rawValue != 0
    }

    var hasBinaryPrefix: Bool {
        return flags & FillingFlag.BINARY_PREFIX.rawValue != 0
    }

    var filling: Character {
        return flags & FillingFlag.ZERO.rawValue != 0 ? "0" : " "
    }

    var numberPrefix: String {
        if flags & FillingFlag.PLUS_PREFIX.rawValue != 0 {
            return "+"
        } else if flags & FillingFlag.SPACE_PREFIX.rawValue != 0 {
            return " "
        } else {
            return ""
        }
    }

    func intToString<T: IntegerType>(a: T) -> String {
        if a > 0 {
            return numberPrefix + "\(a)"
        } else {
            return "\(a)"
        }
    }

    // This is not a generic function that handles FloatingPointType;
    // this is because Float80 doesn't confirm FloatingPointType as of Swift 1.1
    func floatToString(a: Double) -> String {
        let fractionPart = abs(a % 1.0)
        let intPart = IntMax(a)

        if precisionOrMaxWidth == Int.max {
            // as possible as natural
            if fractionPart == 0.0 {
                return intToString(intPart)
            } else {
                if a.isSignMinus {
                    return "\(a)"
                } else {
                    return numberPrefix + "\(a)"
                }
            }
        } else {
            let f = makeFractionString(fractionPart)
            if a.isSignMinus {
                return "\(intPart).\(f)"
            } else {
                return numberPrefix + "\(intPart).\(f)"
            }
        }
    }

    func makeFractionString(fractionPart: Double) -> String {
        let v = fractionPart * pow(10, Double(precisionOrMaxWidth))
        return "\(IntMax(v))"
    }

    func fill(s: String) -> String {
        let w = countElements(s) // XXX: should use visual width?

        if hasLeftJustifyFlag {
            // use a space for filling in left-jusitfy mode
            return s + String(count: max(minWidth - w, 0), repeatedValue: Character(" "))
        } else {
            // right-justify mode
            return String(count: max(minWidth - w, 0), repeatedValue: filling) + s
        }
    }
}

enum FillingFlag: UInt {
    case SPACE_PREFIX  = 0b00000001
    case PLUS_PREFIX   = 0b00000010
    case LEFT_JUSTIFY  = 0b00000100
    case ZERO          = 0b00001000
    case BINARY_PREFIX = 0b00010000

    init?(_ c: Character) {
        switch c {
        case " ":
            self = .SPACE_PREFIX
        case "+":
            self = .PLUS_PREFIX
        case "-":
            self = .LEFT_JUSTIFY
        case "0":
            self = .ZERO
        case "#":
            self = .BINARY_PREFIX
        default:
            return nil
        }
    }
}

public struct StringFormatter<StringT: CollectionType where StringT.Generator.Element == Character> {


    typealias SourceType = StringT

    let template: SourceType
    let args: [Any?]
    let nilToken: String

    init(_ template: SourceType, _ args: [Any?], _ nilToken: String) {
        self.template = template
        self.args = args
        self.nilToken = nilToken
    }

    func process() -> String {
        var result = ""

        var argIndex = 0

        var i = template.startIndex
        let endIndex = template.endIndex
        while i != endIndex {
            switch template[i] {
            case "%":
                let (s, nextIndex, nextArgIndex) = processDirective(i.successor(), argIndex)
                result += s
                i = nextIndex
                argIndex = nextArgIndex
            case (let c):
                result.append(c)
                i++
            }
        }
        return result
    }

    func processDirective(index: SourceType.Index, _ argIndex: Int) -> (String, SourceType.Index, Int) {
        if template[index] == "%" {
            return ("%", index.successor(), argIndex)
        }

        var i = index

        // format attributes
        let attr = processAttribute(&i)
        var a: Int
        var nextArgIndex: Int
        if let v = attr.argIndex {
            a = v
            nextArgIndex = argIndex
        } else {
            a = argIndex
            nextArgIndex = argIndex.successor()
        }

        // dispatch by argument type

        switch template[i] {
        case "s", "@" /* ok? */:
            return (toString(attr, args[a]), i.successor(), nextArgIndex)
        case "d":
            return (toDecimalString(attr, args[a]), i.successor(), nextArgIndex)
        case "f":
            return (toFloatString(attr, args[a]), i.successor(), nextArgIndex)
        case (let c):
            fatalError("Unexpected template format: \(c)")
        }
    }

    func processAttribute(inout i: SourceType.Index) -> FormatAttribute {
        let (argIndex, flags, minWidth) = processAttribute0(&i)

        var precisionOrMaxWidth = Int.max
        if template[i] == "." {
            i++
            precisionOrMaxWidth = 0
            if let v = readInt(&i) {
                precisionOrMaxWidth = v
            }
        }

        return FormatAttribute(argIndex: argIndex, flags: flags, minWidth: minWidth, precisionOrMaxWidth: precisionOrMaxWidth)
    }

    func processAttribute0(inout i: SourceType.Index) -> (Int?, UInt, Int) {
        var minWidth = 0
        var argIndex: Int? = nil

        // optional argument index (or min width)
        if let v = readInt(&i) {
            if template[i] == "$" { // argument index
                i++
                argIndex = v - 1 // argument index is 1 origin
            } else {
                return (nil, 0, v)
            }
        }

        // format flags

        var flags: UInt = 0
        while let f = FillingFlag(template[i]) {
            flags |= f.rawValue
            i++
        }

        if let v = readInt(&i) {
            minWidth = v
        }

        return (argIndex, flags, minWidth)
    }


    func charToInt(c: Character) -> Int {
        return String(c).toInt() ?? 0
    }


    func readInt(inout i: SourceType.Index) -> Int? {
        var value = 0
        switch template[i] {
        case let c where ("1" ... "9").contains(c):
            value = charToInt(c)
            i++
        default:
            return nil
        }
        DECIMAL_VALUES: while true {
            switch template[i] {
            case let c where ("0" ... "9").contains(c):
                value = value * 10 + charToInt(c)
                i++
            default:
                break DECIMAL_VALUES
            }
        }

        return value
    }


    func toString(attr: FormatAttribute, _ a: Any?) -> String {
        let s = attr.fill("\(a ?? nilToken)")

        // truncate by max width; O(maxWidth)
        if attr.precisionOrMaxWidth != Int.max {
            var end = s.startIndex
            var maxWidth = attr.precisionOrMaxWidth
            while end != s.endIndex && maxWidth != 0 {
                end++
                maxWidth--
            }
            return s[s.startIndex ..< end]
        } else {
            return s
        }
    }

    func toDecimalString(attr: FormatAttribute, _ a: Any?) -> String {
        switch a ?? 0 {
        case let v as Int:
            return attr.fill(attr.intToString(v))
        case let v as IntMax:
            return attr.fill(attr.intToString(v))
        case let v as Float:
            return toDecimalString(attr, IntMax(v))
        case let v as Double:
            return toDecimalString(attr, IntMax(v))
        case let v as Float80:
            return toDecimalString(attr, IntMax(v))
        case let v:
            return toDecimalString(attr, atoll("\(v)"))
        }
    }

    func toFloatString(attr: FormatAttribute, _ a: Any?) -> String {
        switch a ?? 0.0 {
        case let v as Int:
            return toFloatString(attr, Double(v))
        case let v as IntMax:
            return toFloatString(attr, Float80(v))
        case let v as Float:
            return attr.fill(attr.floatToString(Double(v)))
        case let v as Double:
            return attr.fill(attr.floatToString(v))
        case let v:
            return toFloatString(attr, atof("\(v)"))
        }
    }
}

public func format(template: String, args: Any?...) -> String {
    return StringFormatter(template, args, "(nil)").process()
}
