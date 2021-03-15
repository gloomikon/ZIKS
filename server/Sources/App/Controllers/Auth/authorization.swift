import Vapor

struct User: Content {
    enum Right: String, Content {
        case read = "READ"
        case write = "WRITE"
        case delete = "DELETE"
        case modifyRights = "MODIFY_RIGHTS"
    }

    let login: String
    let password: String
    var rights: [Right]

    init(
        login: String,
        password: String,
        rights: [User.Right]
    ) {
        self.login = login
        self.password = password
        self.rights = rights
    }
}

enum AuthorizationError: Error {
    case invalidUserID
    case userNotFound
}

class UsersContainer {
    var users: [User] = []
    
    init(with users: [User]) {
        self.users = users
    }

    func findUser(by login: String) -> User? {
        return users.first(where: { $0.login == login })
    }

    private func findUserIndex(by login: String) -> Int? {
        return users.firstIndex(where: { $0.login == login })
    }

    func updateUserRights(_ login: String, rights: [User.Right]) -> User? {
        guard let userIndex = findUserIndex(by: login) else {
            return nil
        }

        users[userIndex].rights = rights
        return users[userIndex]
    }

    func verifyUser(with login: String, and password: String) -> User? {
        return users.first(where: { $0.login == login && $0.password == password })
    }
}
