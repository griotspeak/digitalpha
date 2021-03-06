//
//  Main.swift
//  Digitalpha
//
//  Created by TJ Usiyan on 2017/07/09.
//  Copyright © 2017 Buttons and Lights LLC. All rights reserved.
//

import Foundation
private enum Spot {
    case one
    case ten
    case hundred
    case thousand

    init?(_ input: Int) {
        switch input {
        case 0...19:
            self = .one
        case 20...99:
            self = .ten
        case 100...999:
            self = .hundred
        default:
            if input >= 1000 && Double(input) <= 0.1 * pow(base: 10, exponent: (1 + (Spot.thousand.values.count * 3))) {
                self = .thousand
            } else {
                return nil
            }
        }
    }

    subscript (_ index: Int) -> String {
        return values[index]!
    }

    private var values: [String?] {
        switch self {
        case .one:
            return ["zero",
                    "one",
                    "two",
                    "three",
                    "four",
                    "five",
                    "six",
                    "seven",
                    "eight",
                    "nine",
                    "ten",
                    "eleven",
                    "twelve",
                    "thirteen",
                    "fourteen",
                    "fifteen",
                    "sixteen",
                    "seventeen",
                    "eighteen",
                    "nineteen"]
        case .ten:
            return [nil,
                    nil,
                    "twenty",
                    "thirty",
                    "forty",
                    "fifty",
                    "sixty",
                    "seventy",
                    "eighty",
                    "ninety"]
        case .hundred:
            return ["hundred"]
        case .thousand:
            return [nil,
                    "thousand",
                    "million",
                    "billion",
                    "trillion",
                    "quadrillion",
                    "quintillion",
                    "sextillion",
                    "septillion",
                    "octillion",
                    "nonillion",
                    "decillion",
                    "undecillion",
                    "duodecillion",
                    "tredecillion",
                    "quattuordecillion",
                    "quindecillion",
                    "sexdecillion",
                    "septendecillion",
                    "octodecillion",
                    "novemdecillion",
                    "vigintillion",
                    "unvigintillion",
                    "duovigintillion",
                    "tresvigintillion",
                    "quattuorvigintillion",
                    "quinquavigintillion",
                    "sesvigintillion",
                    "septemvigintillion",
                    "octovigintillion",
                    "novemvigintillion",
                    "trigintillion",
                    "untrigintillion",
                    "duotrigintillion",
                    "trestrigintillion",
                    "quattuortrigintillion",
                    "quinquatrigintillion",
                    "sestrigintillion",
                    "septentrigintillion",
                    "octotrigintillion",
                    "noventrigintillion",
                    "quadragintillion"]
        }
    }

    var rawValue: Int {
        switch self {
        case .one:
            return 1
        case .ten:
            return 10
        case .hundred:
            return 100
        case .thousand:
            return 1000
        }
    }
}

func pow(base: Int, exponent: Int) -> Double {
    precondition(exponent >= 0, "exponent must not be negative")
    switch exponent {
    case 0:
        return 1
    case 1:
        return Double(base)
    default:
        return Double(Array(repeating: Double(base), count: exponent).reduce(1, *))
    }
}

extension Int {
    public enum BaseStringFormat {
        public enum UseCase {
            case cardinal
            case ordinal
        }

        case spelledOutEnglish(UseCase, specialConnector: String?)
        case arabicNumerals(UseCase)

        static let defaultSpecialConnector: String = " "
    }


    public func described(format: BaseStringFormat) -> String {
        switch format {
        case .arabicNumerals(.ordinal):
            return ordinalString()
        case .arabicNumerals(.cardinal):
            return cardinalStringSpelledOut()
        case .spelledOutEnglish(.ordinal, let specialConnector):
            return ordinalStringSpelledOut(specialConnector: specialConnector ?? BaseStringFormat.defaultSpecialConnector)
        case .spelledOutEnglish(.cardinal, let specialConnector):
            return cardinalStringSpelledOut(specialConnector: specialConnector ?? BaseStringFormat.defaultSpecialConnector)
        }
    }

    private func cardinalStringSpelledOut(specialConnector: String = " ") -> String {
        guard self >= 0 else {
            return "negative \((-self).cardinalStringSpelledOut(specialConnector:specialConnector))"
        }

        func cardinalAppend(scratch: Int, connector: String, accumulator: String, calls: Set<Spot>) -> (value: String, calls: Set<Spot>) {
            let key = Spot(scratch)! /* TODO: when does this crash? Does it? Can types help?  h 2017-07-09 */
            let rawKey = key.rawValue
            let backCalls = calls.union([key])

            switch key {
            case .one where accumulator.isEmpty == false && scratch == 0:
                return (accumulator.trimmingCharacters(in: [" ", "-"]) + " ", backCalls)
            case .one where backCalls.subtracting([.one, .ten]).isEmpty == false:
                let back = accumulator.trimmingCharacters(in: [" "])
                return ("\(back)\(connector)\(key[scratch]) ", backCalls)
            case .one:
                return ("\(accumulator)\(key[scratch]) ", backCalls)
            case .ten:
                let count = (scratch - (scratch % rawKey)) / rawKey
                let newNum = (scratch - (count * rawKey))
                let newAccum: String
                if calls.subtracting([.one, .ten]).isEmpty {
                    newAccum = "\(accumulator)\(key[count])-"
                } else {
                    let string = accumulator.trimmingCharacters(in: [" "])
                    newAccum = "\(string)\(connector)\(key[count])-"
                }
                return cardinalAppend(scratch: newNum, connector: connector, accumulator: newAccum, calls: [])
            case .hundred:
                let count = (scratch - (scratch % rawKey)) / rawKey
                let newNum = (scratch - (count * rawKey))
                var newString: String = cardinalAppend(scratch: count, connector: connector, accumulator: accumulator, calls: []).value
                newString.append(Spot.hundred[0])
                newString.append(" ")
                return cardinalAppend(scratch: newNum, connector: connector, accumulator: newString, calls: backCalls)
            case .thousand:
                let divModResult = (scratch.placeWidth() - 1).divMod(3)
                let chunk = Int(exactly: pow(base: 10, exponent: divModResult.quotient * 3))!
                let count = (scratch - (scratch % chunk)) / chunk
                let newNumber = scratch - (chunk * count)
                var newString: String = cardinalAppend(scratch: count, connector: connector, accumulator: accumulator, calls: []).value
                newString.append(Spot.thousand[divModResult.quotient])
                newString.append(" ")
                return cardinalAppend(scratch: newNumber, connector: connector, accumulator: newString, calls: backCalls)
            }
        }

        return cardinalAppend(scratch: self, connector: specialConnector, accumulator: "", calls: []).value.trimmingCharacters(in: [" "])
    }

    private func ordinalString() -> String {
        let selfString = String(self)

        if (10...20 ~= (abs(self) % 100)) {
            return selfString + "th"
        }

        switch self % 10 {
        case 1:
            return selfString + "st"
        case 2:
            return selfString + "nd"
        case 3:
            return selfString + "rd"
        default:
            return selfString + "th"
        }
    }

    private func ordinalStringSpelledOut(specialConnector: String = " ") -> String {
        let source = cardinalStringSpelledOut()
        let comps = source.components(separatedBy: specialConnector).flatMap { $0.components(separatedBy: "-") }
        guard let tail = comps.last else {
            fatalError("splitting string failed. Array shouldn't be empty even when separator is not present.")
        }

        switch tail {
        case "one":
            return (source.consuming(suffix: tail) ?? source) + "first"
        case "two":
            return (source.consuming(suffix: tail) ?? source) + "second"
        case "three":
            return (source.consuming(suffix: tail) ?? source) + "third"
        case "five":
            return (source.consuming(suffix: tail) ?? source) + "fifth"
        case "twelve":
            return (source.consuming(suffix: tail) ?? source) + "twelfth"
        default:
            let shouldDropLast: Bool
            let newTail: String

            switch tail.characters.last! {
            case "y":
                shouldDropLast = true
                newTail = "ieth"
            case "t":
                shouldDropLast = false
                newTail = "h"
            case "e":
                shouldDropLast = true
                newTail = "th"
            case _:
                shouldDropLast = false
                newTail = "th"
            }

            if shouldDropLast {

                return (source.consuming(suffix: tail) ?? source) + tail.substring(to: tail.index(before: tail.endIndex)) + newTail
            } else {
                return source + newTail
            }
        }
    }

    private func divMod(_ other: Int) -> (quotient: Int, modulus: Int) {
        let quotient = self / other
        let remainder = self % other

        if quotient > 0 {
            return (quotient, remainder)
        } else if (remainder == 0) {
            return (quotient, remainder)
        } else if quotient == 0  && (self > 0) && (other < 0) {
            let div = quotient - 1
            let result = (div * other) - self
            return (div, -result)
        } else {
            let signSituation = ((self > 0) || (other < 0))
            let div = ((quotient == 0) && signSituation) ? quotient : quotient - 1
            let result = abs((div * other) - self)
            return (div, (other < 0) ? -result : result)
        }
    }

    private func placeWidth(radix: Int = 10) -> Int {
        func _doIt(accumulated: Int, radix: Int = 10, depth: Int) -> (depth: Int, accumulated: Int) {
            if accumulated < radix {
                return (depth + 1, 0)
            }

            let back = (accumulated - (accumulated % radix)) / radix
            return _doIt(accumulated: back, radix: radix, depth: depth + 1)
        }

        return _doIt(accumulated: self, radix: radix, depth: 0).depth
    }
}

extension String {
    fileprivate func consuming(suffix: String) -> String? {
        let starts: [CharacterView.Index] = characters.indices.reduce([]) { (accum, element) in
            if self.substring(from: element).hasPrefix(suffix) {
                return accum + [element]
            } else {
                return accum
            }
        }

        if let lastStart = starts.last {
            return self.substring(to: lastStart)
        } else {
            return nil
        }
    }
}
