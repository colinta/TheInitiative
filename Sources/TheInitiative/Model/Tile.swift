////
///  Tile.swift
//

struct Tile {
    let x: Int
    let y: Int
    let c: Terrain

    init(_ x: Int, _ y: Int, _ c: Terrain) {
        self.x = x
        self.y = y
        self.c = c
    }
}
