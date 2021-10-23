////
///  Root.swift
//

import Ashen

struct Root {
    struct Model {
        let initiative: Initiative.Model
        let game: Game.Model
        let login: Login.Model?
        let active: App
    }

    enum App {
        case initiative
        case game
        case login
    }

    enum Message {
        case initiative(Initiative.Message)
        case game(Game.Message)
        case login(Login.Message)
        case select(App)
        case quit
    }

    static func initial() -> Initial<Model, Message> {
        let initiative = Initiative.initial()
        let game = Game.initial()
        let login = Login.initial()

        return Initial(
            Model(
                initiative: initiative.model,
                game: game.model,
                login: login.model,
                active: .login),
            command: Command<Message>.list([
                initiative.command.map(Message.initiative),
                game.command.map(Message.game),
                login.command.map(Message.login),
            ]))
    }

    static func unmount(model: Model) {
        Game.unmount(model.game)
    }

    static func update(model: Model, message: Message) -> State<Model, Message> {
        switch message {
        case let .login(.delegate(.login(user))):
            debug("user: \(user)")
            return .model(
                Model(initiative: model.initiative, game: model.game, login: nil, active: .game)
            )
        case let .initiative(message):
            return Initiative.update(model: model.initiative, message: message).map {
                initiative, cmd in
                return (
                    Model(initiative: initiative, game: model.game, login: model.login, active: model.active),
                    cmd.map(Message.initiative)
                )
            }
        case let .game(message):
            return Game.update(model: model.game, message: message).map { game, cmd in
                return (
                    Model(initiative: model.initiative, game: game, login: model.login, active: model.active),
                    cmd.map(Message.game)
                )
            }
        case let .login(message):
            guard let login = model.login else { return .noChange }
            return Login.update(model: login, message: message).map { login, cmd in
                return (
                    Model(initiative: model.initiative, game: model.game, login: login, active: model.active),
                    cmd.map(Message.login)
                )
            }
        case let .select(app):
            if model.active == app {
                return .noChange
            } else if app == .login {
                let login = Login.initial()
                return .update(
                    Model(initiative: model.initiative, game: model.game, login: login.model, active: .login),
                    login.command.map(Message.login)
                )
            }
            return .model(Model(initiative: model.initiative, game: model.game, login: nil, active: app))
        case .quit:
            return .quit
        }
    }

    static func render(model: Model) -> [View<Message>] {
        let app: [View<Message>]
        switch model.active {
        case .initiative:
            app = Initiative.render(model: model.initiative).map { $0.map(Message.initiative) }
        case .game:
            app = Game.render(model: model.game).map { $0.map(Message.game) }
        case .login:
            if let login = model.login {
                return Login.render(model: login).map { $0.map(Message.login) }
            } else {
                return []
            }
        }
        return [
            Flow(
                .topToBottom,
                [
                    (.flex1, Window(app)),
                    (
                        .fixed,
                        Flow(
                            .leftToRight,
                            [
                                (.flex1, Repeating(Text("─"))),
                                (.fixed, Text("┬")),
                                (.flex1, Repeating(Text("─"))),
                            ])
                    ),
                    (
                        .fixed,
                        Flow(
                            .leftToRight,
                            [
                                (
                                    .flex1,
                                    OnLeftClick(
                                        Text(
                                            "Initiative".styled(
                                                model.active == .initiative ? .bold : .none)),
                                        .select(.initiative))
                                ),
                                (.fixed, Text("|")),
                                (
                                    .flex1,
                                    OnLeftClick(
                                        Text(
                                            "Map \(model.game.isLoading ? "…" : "")".styled(
                                                model.active == .game ? .bold : .none)),
                                        .select(.game))
                                ),
                            ])
                    ),
                ])
        ]
    }
}
