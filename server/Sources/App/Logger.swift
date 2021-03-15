import Foundation
import Vapor

class RequestLogger {
    enum Result: String {
        case success = "SUCCESS"
        case failure = "FAILURE"
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }()

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func log(to file: String = "default", req: Request, result: Result, info: String) {
        let filename = getDocumentsDirectory().appendingPathComponent("\(file).csv")

        let csvString = "\(req.method)\t \(req.url)\t \(dateFormatter.string(from: Date()))\t \(result.rawValue)\t \(info)"

        do {
            try csvString.appendLineToURL(fileURL: filename)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Data {
     func append(fileURL: URL) throws {
         if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
             defer {
                 fileHandle.closeFile()
             }
             fileHandle.seekToEndOfFile()
             fileHandle.write(self)
         }
         else {
             try write(to: fileURL, options: .atomic)
         }
     }
 }

extension String {
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
     }

     func appendToURL(fileURL: URL) throws {
         let data = self.data(using: String.Encoding.utf8)!
         try data.append(fileURL: fileURL)
     }
 }
