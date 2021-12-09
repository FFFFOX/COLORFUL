import Foundation

func delay(_ delay: TimeInterval, mainThread: Bool = true, block: @escaping () -> Void) {
    let queue: DispatchQueue
    if mainThread {
        queue = DispatchQueue.main
    } else {
        queue = DispatchQueue.global()
    }
    queue.asyncAfter(deadline: .now() + delay) {
        block()
    }
}
