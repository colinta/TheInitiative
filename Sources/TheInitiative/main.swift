import ArgumentParser
import Ashen
import Firebase
import FirebaseDatabase
import Foundation

@main
struct Main: ParsableCommand {
    @Option(name: [.customShort("d"), .customLong("db")])
    var db: String

    func run() throws {
        guard
            let options = FirebaseOptions(
                contentsOfFile: "Sources/Firebase/GoogleService-Info.plist")
        else {
            print("Could not find GoogleService-Info.plist")
            return
        }
        options.databaseURL = "https://$db.firebaseio.com/"
        FirebaseApp.configure(options: options)
        FirebaseConfiguration.shared.setLoggerLevel(.max)

        let map: [[String]] = [
            "◼..◼........X..X......",
            ".◼◼◼◼◼◼◼◼....XXXXXXXX.",
            "◼◼....◼.◼◼..XX....X.XX",
            ".◼...◼◼◼◼....X...XXXX.",
            ".◼....◼.◼....X....X.X.",
            ".◼◼◼◼◼◼◼◼....XXXXXXXX.",
            "...◼...........X......",
        ].map { (line: String) -> [String] in
            Array(line).map(String.init)
                .map { c in
                    switch c {
                    case "X":
                        return "rock"
                    case "◼":
                        return "wall"
                    default:
                        return "grass"
                    }
                }
        }
        let ref = Database.database().reference()
        var i = 0
        for (y, row) in map.enumerated() {
            for (x, terrain) in row.enumerated() {
                ref.child("games").child("test").child("map").updateChildValues([
                    "\(i)": [
                        "x": x,
                        "y": y,
                        "c": terrain,
                    ]
                ])
                i += 1
            }
        }

        try ashen(Ashen.Program(Root.initial, Root.update, Root.render, Root.unmount))
    }
}
