//
//  Main.swift
//  Digitalpha
//
//  Created by TJ Usiyan on 2017/07/09.
//  Copyright © 2017 Buttons and Lights LLC. All rights reserved.
//

import Foundation

var lookup: [Int:[String?]] {
    return [
        1:
            ["zero",
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
             "nineteen"],
        10:
            [nil,
             nil,
             "twenty",
             "thirty",
             "forty",
             "fifty",
             "sixty",
             "seventy",
             "eighty",
             "ninety",
             "hundred"],
        1000:
            [nil,
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
             "vigintillion"]]
}

func extract(number: [Int], connector: String, accumulator: String, calls: Set<Int>) -> (value: String, calls: Set<Int>) {
    let scratch = number[0]
    let key = keyToUse(scratch)! /* TODO: when does this crash? Does it? Can types help?  h 2017-07-09 */
    let backCalls = calls.union([key])

    switch key {
    case 1 where accumulator.isEmpty == false && scratch == 0:
        return (accumulator.trimmingCharacters(in: [" ", "-"]) + " ", backCalls)
    case 1 where backCalls.subtracting([1, 10]).isEmpty == false:
        let back = accumulator.trimmingCharacters(in: [" "])
        return ("\(back)\(connector)\(lookup[key]![scratch]!) ", backCalls)
    case 1:
        return ("\(accumulator)\(lookup[key]![scratch]!) ", backCalls)
    case 10:
        let count = (scratch - (scratch % key)) / key
        let newNum = [(scratch - (count * key))]
        let newAccum: String
        if calls.subtracting([1, 10]).isEmpty {
            newAccum = "\(accumulator)\(lookup[key]![count]!)-"
        } else {
            let string = accumulator.trimmingCharacters(in: [" "])
            newAccum = "\(string)\(connector)\(lookup[key]![count]!)-"
        }
        return extract(number: newNum, connector: connector, accumulator: newAccum, calls: [])
    case 100:
        let count = (scratch - (scratch % key)) / key
        let newNum = [(scratch - (count * key))]
        var newString: String = extract(number: [count], connector: connector, accumulator: accumulator, calls: []).value
        newString.append(lookup[10]![10]!)
        newString.append(" ")
        return extract(number: newNum, connector: connector, accumulator: newString, calls: backCalls)
    case 1000:
        let divModResult = (scratch.placeWidth() - 1).divMod(3)
        let chunk = Int(exactly: pow(base: 10, exponent: divModResult.quotient * 3))!
        let count = (scratch - (scratch % chunk)) / chunk
        let newNumber = [scratch - (chunk * count)]
        var newString: String = extract(number: [count], connector: connector, accumulator: accumulator, calls: []).value
        newString.append(lookup[1000]![divModResult.quotient]!)
        newString.append(" ")
        return extract(number: newNumber, connector: connector, accumulator: newString, calls: backCalls)
    default:
        fatalError("Unexpected key")
    }
}


func keyToUse(_ input: Int) -> Int? {
    switch input {
    case 0...19:
        return 1
    case 20...99:
        return 10
    case 100...999:
        return 100
    default:
        if input >= 1000 && Double(input) <= 0.1 * pow(base: 10, exponent: (1 + (lookup[1000]!.count * 3))) {
            return 1000
        } else {
            return nil
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


    public func cardinalStringSpelledOut(specialConnector: String = " ") -> String {
        guard self >= 0 else {
            return "negative \((-self).cardinalStringSpelledOut(specialConnector:specialConnector))"
        }

        return extract(number: [self], connector: specialConnector, accumulator: "", calls: []).value.trimmingCharacters(in: [" "])
    }

    public func ordinalString() -> String {
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

    public func ordinalStringSpelledOut(specialConnector: String = " ") -> String {
        let source = cardinalStringSpelledOut()
        let comps = source.components(separatedBy: specialConnector).flatMap { $0.components(separatedBy: "-") }

        let tail = comps.last!

        switch tail {
        case "one":
            return source.chomp(tail) + "first"
        case "two":
            return source.chomp(tail) + "second"
        case "three":
            return source.chomp(tail) + "third"
        case "five":
            return source.chomp(tail) + "fifth"
        case "twelve":
            return source.chomp(tail) + "twelfth"
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
                return source.chomp(tail) + tail.substring(to: tail.index(before: tail.endIndex)) + newTail
            } else {
                return source + newTail
            }
        }
    }

    internal func divMod(_ other: Int) -> (quotient: Int, modulus: Int) {
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

    func placeWidth(radix: Int = 10) -> Int {
        var back = 1
        var value = abs(self)

        while value >= radix {
            back += 1
            value = (value - (value % radix)) / radix
        }

        return back
    }
}

extension String {
    func chomp(_ substring: String) -> String {
        let starts: [CharacterView.Index] = characters.indices.reduce([]) { (accum, element) in
            if self.substring(from: element).hasPrefix(substring) {
                return accum + [element]
            } else {
                return accum
            }
        }

        if let lastStart = starts.last {
            return self.substring(to: lastStart)
        } else {
            return self
        }
    }
}



//
//0.ordinalString()
//1.ordinalString()
//2.ordinalString()
//3.ordinalString()
//4.ordinalString()
//5.ordinalString()
//6.ordinalString()
//7.ordinalString()
//8.ordinalString()
//9.ordinalString()
//10.ordinalString()
//11.ordinalString()
//12.ordinalString()
//13.ordinalString()
//14.ordinalString()
//15.ordinalString()
//16.ordinalString()
//17.ordinalString()
//18.ordinalString()
//19.ordinalString()
//20.ordinalString()
//21.ordinalString()
//22.ordinalString()
//23.ordinalString()
//24.ordinalString()
//25.ordinalString()
//26.ordinalString()
//27.ordinalString()
//28.ordinalString()
//29.ordinalString()
//40.ordinalString()
//41.ordinalString()
//42.ordinalString()
//43.ordinalString()
//44.ordinalString()
//45.ordinalString()
//46.ordinalString()
//47.ordinalString()
//48.ordinalString()
//49.ordinalString()
//
//1.cardinalStringSpelledOut()
//2.cardinalStringSpelledOut()
//
//412.cardinalStringSpelledOut(specialConnector: " and ")
