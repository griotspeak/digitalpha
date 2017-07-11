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


func extract(number: [Int], connector: String, accumulator: String, calls: inout Set<Int>) -> String {
    let scratch = number[0]
    let key = keyToUse(scratch)! /* TODO: when does this crash? Does it? Can types help?  h 2017-07-09 */
    calls.formUnion([key])

    switch key {
    case 1 where accumulator.isEmpty == false && scratch == 0:
        var back = accumulator.trimmingCharacters(in: [" ", "-"])
        back.append(" ")
        return back
    case 1 where calls.subtracting([1, 10]).isEmpty == false:
        let back = accumulator.trimmingCharacters(in: [" "])
        return "\(back)\(connector)\(lookup[key]![scratch]!) "
    case 1:
        return "\(accumulator)\(lookup[key]![scratch]!) "
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
        var _calls = Set<Int>()
        return extract(number: newNum, connector: connector, accumulator: newAccum, calls: &_calls)
    case 100:
        let count = (scratch - (scratch % key)) / key
        let newNum = [(scratch - (count * key))]
        var _calls = Set<Int>()
        var newString = extract(number: [count], connector: connector, accumulator: accumulator, calls: &_calls)
        newString.append(lookup[10]![10]!)
        newString.append(" ")
        return extract(number: newNum, connector: connector, accumulator: newString, calls: &calls)
    case 1000:
        let divModResult = (scratch.placeWidth() - 1).divMod(3)
        let chunk = Int(exactly: pow(base: 10, exponent: divModResult.quotient * 3))!
        let count = (scratch - (scratch % chunk)) / chunk
        let newNumber = [scratch - (chunk * count)]
        var _calls = Set<Int>()
        var newString = extract(number: [count], connector: connector, accumulator: accumulator, calls: &_calls)
        newString.append(lookup[1000]![divModResult.quotient]!)
        newString.append(" ")
        return extract(number: newNumber, connector: connector, accumulator: newString, calls: &calls)
    default:
        return "WAT????????????????????"
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


    public func cardinalStringSpelledOut(firstConnector: String = " and ") -> String {
        guard self >= 0 else {
            return "negative \((-self).cardinalStringSpelledOut(firstConnector:firstConnector))"
        }

        var _calls = Set<Int>()
        return extract(number: [self], connector: firstConnector, accumulator: "", calls: &_calls).trimmingCharacters(in: [" "])
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
//412.cardinalStringSpelledOut(firstConnector: " and ")
