import Vapor

struct SignInData: Content {
    let login: String
    let password: String
}

struct User: Content {
    enum Right: String, Content {
        case read = "READ"
        case write = "WRITE"
        case delete = "DELETE"
        case modifyRights = "MODIFY_RIGHTS"
    }

    let id: UInt
    let login: String
    let password: String
    var rights: [Right]

    init(
        id: UInt,
        login: String,
        password: String,
        rights: [User.Right]
    ) {
        self.id = id
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

    func addUser(_ user: User) throws {
        guard !users.contains(where: { $0.id == user.id}) else {
            throw AuthorizationError.invalidUserID
        }

        users.append(user)
    }

    func findUser(by login: String) -> User? {
        return users.first(where: { $0.login == login })
    }

    func findUserIndex(by login: String) -> Int? {
        return users.firstIndex(where: { $0.login == login })
    }

    func updateUserRights(_ login: String, rights: [User.Right]) -> User? {
        guard let userIndex = findUserIndex(by: login) else {
            return nil
        }

        users[userIndex].rights = rights
        return users[userIndex]
    }

//    func addUsers(_ users: [User]) throws {
//        try users.forEach { user in
//            try addUser(user)
//        }
//    }
//
//    func findUserByID(_ id: UInt) -> User? {
//        return users.first(where: { $0.id == id} )
//    }

    func verifyUser(with login: String, and password: String) -> User? {
        return users.first(where: { $0.login == login && $0.password == password })
    }
}
