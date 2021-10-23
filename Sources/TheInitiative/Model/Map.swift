////
///  Map.swift
//

struct Map {
    let points: [Tile]

    func at(_ x: Int, _ y: Int) -> Terrain? {
        points.first { pt in
            pt.x == x && pt.y == y
        }?.c
    }

    func draw(_ x: Int, _ y: Int, _ c: Terrain) -> Map {
        let points =
            self.points.filter { pt in
                pt.x != x || pt.y != y
            } + [Tile(x, y, c)]
        return Map(points: points)
    }
}
