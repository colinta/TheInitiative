////
///  Login.swift
//

import Ashen
import Firebase
import FirebaseDatabase
import Foundation

struct Login {
    enum State {
        case fresh
        case invalid
        case valid
        case submitting
        case success
        case failed
    }

    enum Field {
        case email
        case password
    }

    struct Model {
        let email: String
        let password: String
        let activeField: Field
        let state: State

        func update(email: String? = nil, password: String? = nil, activeField: Field? = nil, state: State? = nil) -> Model {
            return Model(
                email: email ?? self.email,
                password: password ?? self.password,
                activeField: activeField ?? self.activeField,
                state: state ?? self.state
            )
        }
    }

    enum Delegate {
        case login(User)
    }

    enum Message {
        case delegate(Delegate)
        case begin
        case clear
        case submit
        case next
        case loginSuccess(User)
        case loginFail(Error?)
        case update(Field, String)
    }

    static func initial() -> Initial<Model, Message> {
        return Initial(
            Model(
                email: "",
                password: "",
                activeField: .email,
                state: .fresh
            ), command: Command<Message> { send in
                if let currentUser = Auth.auth().currentUser {
                    send(.loginSuccess(currentUser))
                } else {
                    send(.begin)
                }
            }
        )
    }

    static func update(model: Model, message: Message) -> Ashen.State<Model, Message> {
        switch message {
        case .delegate:
            return .noChange
        case let .loginSuccess(user):
            return .update(model.update(state: .success), Command<Message>.send(.delegate(.login(user))))
        case .loginFail:
            return .model(model.update(state: .failed))
        case .begin:
            return .model(model.update(email: "", password: "", state: .valid))
        case .clear:
            return .model(model.update(email: "", password: "", state: .fresh))
        case .submit:
            guard model.state != .submitting else { return .noChange }

            if model.email.isEmpty || model.password.isEmpty {
                return .model(model.update(state: .invalid))
            }

            let command: Command<Message> = Command { send in
                Auth.auth().signIn(withEmail: model.email, password: model.password) { authResult, error in
                    if let authResult = authResult {
                        send(.loginSuccess(authResult.user))
                    } else if let error = error {
                        send(.loginFail(error))
                    } else {
                        send(.loginFail(nil))
                    }
                }
            }

            return .update(model.update(state: .submitting), command)
        case .next:
            let fields: [Field] = [.email, .password]
            let next = ((fields.firstIndex(of: model.activeField) ?? -1) + 1) % fields.count
            return .model(model.update(activeField: fields[next]))
        case let .update(field, value):
            return .model(
                model.update(
                    email: field == .email ? value : nil,
                    password: field == .password ? value : nil
                )
            )
        }
    }

    static func render(model: Model) -> [View<Message>] {
        if case .success = model.state {
            return []
        } else {
            return [
                Window([
                    OnKeyPress(.enter, .submit),
                    OnKeyPress(.tab, .next),
                    Box(
                        model.state == .submitting || model.state == .fresh
                        ? Spinner().aligned(.middleCenter)
                        : Flow(.down, [
                                (.fixed, Text(
                                    model.state == .invalid ?
                                    "Email and Password are required" :
                                        model.state == .failed ?
                                        "Wrong email and password"
                                        : "")),
                                (.fixed, Space().height(1)),
                                (.fixed, Stack(.ltr, [Text("Email:    "), Input(model.email, onChange: { .update(.email, $0) }, .isResponder(model.activeField == .email))])),
                                (.fixed, Stack(.ltr, [Text("Password: "), Input(model.password, onChange: { .update(.password, $0) }, .isResponder(model.activeField == .password), .isSecure(true))])),
                                (.flex1, Space()),
                                (.fixed, Stack(.rtl, [
                                    Space().width(3),
                                    OnLeftClick(Text("< OK >"), .submit),
                                    OnLeftClick(Text("< Clear >"), .clear),
                                ])),
                            ]),
                        .title("Login")
                    ).background(color: .gray)
                    .size(Size(width: 100, height: 8))
                    .aligned(.middleCenter),
                ]).defaultBackground(color: .darkGray)
            ]
        }
    }
}
