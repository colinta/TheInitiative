////
///  Game.swift
//

import Ashen
import Firebase
import FirebaseDatabase
import Foundation

struct Game {

    struct Model {
        let subs: [Subscription]
        let map: Map
        let isLoading: Bool

        func subscribe(_ subscription: Subscription) -> Self {
            Model(
                subs: subs + [subscription],
                map: map,
                isLoading: isLoading
            )
        }

        func update(map: Map?, isLoading: Bool?) -> Self {
            Model(
                subs: subs,
                map: map ?? self.map,
                isLoading: isLoading ?? self.isLoading
            )
        }

        func unmount() {
            for sub in subs {
                for handle in sub.handles {
                    sub.ref.removeObserver(withHandle: handle)
                }
            }
        }
    }

    enum Message {
        case subscribe(Subscription)
        case draw([Tile])
        case click(Int, Int)
    }

    static func initial() -> Initial<Model, Message> {
        let command = Command<Message> { send in
            let ref = Database.database().reference()
                .child("games")
                .child("test")
                .child("map")
            let handle = ref.observe(.value) { snap in
                guard
                    let pointsRaw = snap.value as? [[String: Any]]
                else { return }
                let points: [Tile] = pointsRaw.compactMap { point -> Tile? in
                    guard
                        let x = point["x"] as? Int,
                        let y = point["y"] as? Int,
                        let c: Terrain = (point["c"] as? String).flatMap({ Terrain(rawValue: $0) })
                    else { return nil }
                    return Tile(x, y, c)
                }
                send(.draw(points))
            }

            send(.subscribe(Subscription(ref: ref, handles: [handle])))
        }
        return Initial(
            Model(
                subs: [],
                map: Map(points: []),
                isLoading: true
            ), command: command)
    }

    static func unmount(_ model: Model) {
        model.unmount()
    }

    static func update(model: Model, message: Message) -> State<Model, Message> {
        switch message {
        case let .click(x, y):
            debug("=============== \(#file) line \(#line) ===============")
            debug("x: \(x)")
            debug("y: \(y)")
            return .noChange
        case let .draw(points):
            return .model(model.update(map: Map(points: points), isLoading: false))
        case let .subscribe(subscription):
            return .model(model.subscribe(subscription))
        }
    }

    static func render(model: Model) -> [View<Message>] {
        model.map.points.map { pt in
            let (x, y) = (pt.x, pt.y)
            let (drawX, drawY) = (x * 5, y * 3)

            return OnLeftClick(
                Text(
                    pt.c.text(
                        x: x, y: y,
                        l: model.map.at(x - 1, y),
                        r: model.map.at(x + 1, y),
                        u: model.map.at(x, y - 1),
                        d: model.map.at(x, y + 1))
                ).background(color: pt.c.bg),
                Message.click(x, y)
            )
            .width(5).height(3)
            .offset(x: drawX, y: drawY)
        }
    }
}
