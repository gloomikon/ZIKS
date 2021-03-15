import Vapor

let admin = User(
    id: 1,
    login: "admin", /* "admin */
    password: "21232f297a57a5a743894a0e4a801fc3", /* "admin */
    rights: [.read, .write, .delete, .modifyRights]
)

let mzhurba = User(
    id: 2,
    login: "mzhurba", /* "mzhurba" */
    password: "e1ea6fa2cb9705e965f13086681cfd67", /* "mzurba" */
    rights: [.read, .write]
)

let opiskun = User(
    id: 1,
    login: "opiskun", /* "opiskun" */
    password: "614480e40d9a674ace7e60b5c2e39451", /* "opiskun" */
    rights: [.read]
)

let usersContainer = UsersContainer(with: [admin, mzhurba, opiskun])

var data = [
    "Lorem ipsum",
    "Lorem ipsum",
    "Lorem ipsum",
    "123456",
    "mzhurba test",
    "adnmin admin",
    "opiskun test",
    "some more info",
    "test text",
    "❤️🦖"
]

let logger = RequestLogger()

func routes(_ app: Application) throws {
    // MARK: - User related routes

    /*
     * Used when user authorizes in the app. Returns user instance if login was successful
     */

    app.get("user") { req -> User in

        guard let login = req.query[String.self, at: "login"],
              let password = req.query[String.self, at: "password"] else {
            logger.log(
                req: req,
                result: .failure,
                info: "No needed query params were provided"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.verifyUser(with: login, and: password) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(login) and password \(password)"
            )
            throw AuthorizationError.userNotFound
        }

        logger.log(
            req: req,
            result: .success,
            info: "User \(login) entered with password \(password)"
        )

        return user
    }

    /*
     * Returns all users
     */

    app.get("users") { req -> [User] in
        guard let login = req.query[String.self, at: "login"] else {
            logger.log(
                req: req,
                result: .failure,
                info: "Incorrect parameters format"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.findUser(by: login) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(login)"
            )

            throw AuthorizationError.userNotFound
        }

        guard user.rights.contains(.modifyRights) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "User has no rights to read data"
            )
            throw Abort(.forbidden)
        }

        logger.log(
            to: user.login,
            req: req,
            result: .success,
            info: "Read info about users"
        )

        return usersContainer.users
    }

    /*
     * Updated the user rights and returns the updated user
     */

    app.put("user") { req -> [User] in
        struct DataInput: Content {
            let changer: String
            let login: String
            let rights: [User.Right]
        }

        guard let dataInput = try? req.content.decode(DataInput.self) else {
            logger.log(
                req: req,
                result: .failure,
                info: "Incorrect parameters format"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.findUser(by: dataInput.changer) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(dataInput.changer)"
            )

            throw AuthorizationError.userNotFound
        }

        guard user.rights.contains(.modifyRights) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "User has no rights to modify rights"
            )

            throw Abort(.forbidden)
        }

        guard let _ = usersContainer.updateUserRights(dataInput.login, rights: dataInput.rights) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "Unable to update rights of user with login \(dataInput.login) to \(dataInput.rights.map { $0.rawValue}.joined(separator: " "))"
            )
            throw AuthorizationError.userNotFound
        }

        logger.log(
            to: user.login,
            req: req,
            result: .success,
            info: "Updated rights of user with login \(dataInput.login) to \(dataInput.rights.map { $0.rawValue}.joined(separator: " "))"
        )

        return usersContainer.users
    }

    // MARK: - Data relared routes

    /*
     * Returns all data strings
     */

    app.get("data") { req -> [String] in
        guard let login = req.query[String.self, at: "login"] else {
            logger.log(
                req: req,
                result: .failure,
                info: "Incorrect parameters format"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.findUser(by: login) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(login)"
            )
            throw AuthorizationError.userNotFound
        }

        guard user.rights.contains(.read) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "User has no rights to read data"
            )

            throw Abort(.forbidden)
        }

        logger.log(
            to: user.login,
            req: req,
            result: .success,
            info: "Read data string"
        )
        return data
    }

    /*
     * Adds a new string and returns the resulting array
     */

    app.post("data") { req -> [String] in
        struct DataInput: Content {
            let login: String
            let string: String
        }

        guard let dataInput = try? req.content.decode(DataInput.self) else {
            logger.log(
                req: req,
                result: .failure,
                info: "Incorrect parameters format"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.findUser(by: dataInput.login) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(dataInput.login)"
            )
            throw AuthorizationError.userNotFound
        }

        guard user.rights.contains(.write) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "User has no rights to write data"
            )

            throw Abort(.forbidden)
        }

        logger.log(
            to: user.login,
            req: req,
            result: .success,
            info: "Inserted string with text \(dataInput.string)"
        )

        data.append(dataInput.string)

        return data
    }

    /*
     * Deletes a string at index and returns the resulting array
     */

    app.delete("data") { req -> [String] in
        struct DataInput: Content {
            let login: String
            let index: Int
        }

        guard let dataInput = try? req.content.decode(DataInput.self) else {
            logger.log(
                req: req,
                result: .failure,
                info: "Incorrect parameters format"
            )
            throw Abort(.badRequest)
        }

        guard let user = usersContainer.findUser(by: dataInput.login) else {
            logger.log(
                req: req,
                result: .failure,
                info: "No user found with login \(dataInput.login)"
            )
            throw AuthorizationError.userNotFound
        }

        guard user.rights.contains(.delete) else {
            logger.log(
                to: user.login,
                req: req,
                result: .failure,
                info: "User has no rights to delete data"
            )

            throw Abort(.forbidden)
        }

        logger.log(
            to: user.login,
            req: req,
            result: .success,
            info: "Deleted string at index \(dataInput.index) aka \(data[dataInput.index])"
        )

        data.remove(at: dataInput.index)

        return data
    }
}
