
import Foundation
import LocalAuthentication

let arguments = CommandLine.arguments

if (arguments.count == 2) && (arguments[1] == "-h" || arguments[1] == "--help") {
    print("""
        Usage: touch -reason <reason>
           -reason        The app-provided reason for requesting authentication,
                            which displays in the authentication dialog presented to the user
           -h / --help    Help!
        """)
    exit(1)
}

let standardDefaults = UserDefaults.standard
var reason = standardDefaults.string(forKey: "reason") ??
                "perform an action that requires authentication"

// SSH_ASKPASS format
if (standardDefaults.string(forKey: "reason") == nil) && (arguments.count == 2) {
    let arg = arguments[1]
    let listItems = arg.components(separatedBy: "Key fingerprint ")
    if (listItems.count == 2) && listItems[1].hasPrefix("SHA256:") {
        reason += "\n\n"
        reason += listItems[0]
        reason += "\n\nKey fingerprint: "
        reason += listItems[1]
    }
}

let context = LAContext()
context.localizedFallbackTitle = ""
let semaphore = DispatchSemaphore(value: 0)
var result = 1

context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
    if success {
        result = 0
    } else if let error = error {
        print("\(error.localizedDescription)")
        result = 1
    }
    semaphore.signal()
}

_ = semaphore.wait(wallTimeout: .distantFuture)
exit(Int32(result))
