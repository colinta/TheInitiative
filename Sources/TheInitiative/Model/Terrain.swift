////
///  Terrain.swift
//

import Ashen

enum Terrain: String {
    case grass
    case wall
    case rock

    struct Grass {
        static func text(x: Int, y: Int, l: Terrain?, r: Terrain?, u: Terrain?, d: Terrain?)
            -> String
        {
            if x % 2 == 0 {
                return ". . .\n . . \n. . ."
            } else {
                return " . . \n. . .\n . . "
            }
        }
    }

    struct Rock {
        static func text(x: Int, y: Int, l: Terrain?, r: Terrain?, u: Terrain?, d: Terrain?)
            -> String
        {
            if x % 2 == 0 {
                return "X X X\n X X \nX X X"
            } else {
                return " X X \nX X X\n X X "
            }
        }
    }

    struct Wall {
        static func text(x: Int, y: Int, l: Terrain?, r: Terrain?, u: Terrain?, d: Terrain?)
            -> String
        {
            let index =
                (l == .wall ? 1 << 3 : 0) | (r == .wall ? 1 << 2 : 0) | (u == .wall ? 1 << 1 : 0)
                | (d == .wall ? 1 << 0 : 0)
            return [
                """
                ┌───┐
                │xxx│
                └───┘
                """,
                """
                ┌───┐
                │xxx│
                │xxx│
                """,
                """
                │xxx│
                │xxx│
                └───┘
                """,
                """
                │xxx│
                │xxx│
                │xxx│
                """,
                """
                ┌────
                │xxxx
                └────
                """,
                """
                ┌────
                │xxxx
                │xxx┌
                """,
                """
                │xxx└
                │xxxx
                └────
                """,
                """
                │xxx└
                │xxxx
                │xxx┌
                """,
                """
                ────┐
                xxxx│
                ────┘
                """,
                """
                ────┐
                xxxx│
                ┐xxx│
                """,
                """
                ┘xxx│
                xxxx│
                ────┘
                """,
                """
                ┘xxx│
                xxxx│
                ┐xxx│
                """,
                """
                ─────
                xxxxx
                ─────
                """,
                """
                ─────
                xxxxx
                ┐xxx┌
                """,
                """
                ┘xxx└
                xxxxx
                ─────
                """,
                """
                ┘xxx└
                xxxxx
                ┐xxx┌
                """,
            ][index]
        }
    }

    var bg: Color {
        switch self {
        case .grass:
            return .green
        case .wall:
            return .grayscale(15)
        case .rock:
            return .grayscale(20)
        }
    }

    func text(x: Int, y: Int, l: Terrain?, r: Terrain?, u: Terrain?, d: Terrain?) -> String {
        switch self {
        case .grass: return Grass.text(x: x, y: y, l: l, r: r, u: u, d: d)
        case .wall: return Wall.text(x: x, y: y, l: l, r: r, u: u, d: d)
        case .rock: return Rock.text(x: x, y: y, l: l, r: r, u: u, d: d)
        }
    }
}
