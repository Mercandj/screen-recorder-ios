import UIKit
import ReplayKit

// https://www.appcoda.com/replaykit/
class ViewController: UIViewController, RPPreviewViewControllerDelegate {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet weak var label: UILabel!

    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.syncLabel()
        recordButton.addTarget(self, action: #selector(recordButtonClicked), for: .touchUpInside)
    }

    @objc func recordButtonClicked(_ sender: AnyObject?) {
        if (!isRecording) {
            startRecording()
        } else {
            stopRecording()
        }
    }

    // Override RPPreviewViewControllerDelegate
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }

    private func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }

        recorder.startRecording { [unowned self] (error) in
            guard error == nil else {
                self.isRecording = false
                self.label.text = "Start error"
                print("There was an error starting the recording.")
                return
            }
        }

        print("Started Recording Successfully")
        self.isRecording = true
        self.syncLabel()
    }

    private func stopRecording() {
        recorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")

            let alert = UIAlertController(
                    title: "Recording Finished",
                    message: "Would you like to edit or delete your recording?",
                    preferredStyle: .alert
            )

            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.recorder.discardRecording(handler: { () -> Void in
                    print("Recording successfully deleted.")
                })
            })

            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                preview?.previewControllerDelegate = self
                self.present(preview!, animated: true, completion: nil)
            })

            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)

            self.isRecording = false
            self.syncLabel()
        }
    }

    private func syncLabel() {
        DispatchQueue.main.async {
            if (self.isRecording) {
                self.label.text = "Stop record"
            } else {
                self.label.text = "Start record"
            }
        }
    }
}

