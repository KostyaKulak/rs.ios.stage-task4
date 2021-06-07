import Foundation

struct Point: Equatable {
    var x: Int
    var y: Int
}

final class FillWithColor {

    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        if image.isEmpty || row < 0 || column < 0 || row >= image.count || column >= image[0].count {
            return image
        }
        var result = image
        var queue = [Point(x: row, y: column)]
        var visitedPoints = Array<Point>()
        let elementColor = image[row][column]

        while queue.count > 0 {
            let point = queue.remove(at: 0)
            visitedPoints.append(point)

            if (image[point.x][point.y] == elementColor) {
                result[point.x][point.y] = newColor
            } else {
                continue
            }

            if (point.x - 1) >= 0 {
                let element = Point(x: point.x - 1, y: point.y)
                if !visitedPoints.contains(element) {
                    queue.append(element)
                }
            }
            if (point.x + 1) < image.count {
                let element = Point(x: point.x + 1, y: point.y)
                if !visitedPoints.contains(element) {
                    queue.append(element)
                }
            }
            if (point.y - 1) >= 0 {
                let element = Point(x: point.x, y: point.y - 1)
                if !visitedPoints.contains(element) {
                    queue.append(element)
                }
            }
            if (point.y + 1) < image[row].count {
                let element = Point(x: point.x, y: point.y + 1)
                if !visitedPoints.contains(element) {
                    queue.append(element)
                }
            }
        }
        return result
    }
}