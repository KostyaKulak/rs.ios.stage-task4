import Foundation

public extension Int {

    var roman: String? {
        if self < 1 || self > 3999 {
            return nil
        }
        let yearsMap = [
            1000: "M", 900: "CM", 500: "D", 400: "CD",
            100: "C", 90: "XC", 50: "L", 40: "XL",
            10: "X", 9: "IX", 5: "V", 4: "IV", 1: "I"
        ]
        let yearsKeys = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        var result = String()
        var number = self
        for key in yearsKeys {
            if number >= key {
                let quotient: Int = number / key
                number = number % key
                for _ in 1...quotient {
                    result.append(yearsMap[key]!)
                }
            }
            if number == 0 {
                break
            }
        }
        return result
    }
}
