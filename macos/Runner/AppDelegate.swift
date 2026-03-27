import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    var eventSink: FlutterEventSink?
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
        for i in urls {
            eventSink?(i.absoluteString)
        }
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
        super.applicationDidFinishLaunching(notification)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApplication.shared.windows.first {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true

                window.toolbar = nil
                window.titlebarSeparatorStyle = .none
            }
        }
    }
}
