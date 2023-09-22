

import UIKit
import CoreData
import WebKit


class AttachmentViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate//, CLLocationManagerDelegate
, NSFetchedResultsControllerDelegate , WKUIDelegate, URLSessionDownloadDelegate, WKNavigationDelegate {
    
    var downloadTask: URLSessionDownloadTask?
    var downloadProgressView: CircularProgressView?
    var webViewActivityIndicatorView: UIActivityIndicatorView!
    
    //MARK: Properties
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var b_download: UIBarButtonItem!
    
    var melkDetailAttachment: MelkDetailAttachmentEntity? = nil
    let barHeight: CGFloat = 50
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self

        downloadProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 200, height:200))
        downloadProgressView?.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(downloadProgressView!)
        
        if let downloadProgressView = downloadProgressView {
            NSLayoutConstraint.activate([
                downloadProgressView.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
                downloadProgressView.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
                downloadProgressView.widthAnchor.constraint(equalToConstant: 200), // Set your preferred width
                downloadProgressView.heightAnchor.constraint(equalToConstant: 200) // Set your preferred height
            ])
        }
        
        webViewActivityIndicatorView = UIActivityIndicatorView(style: .large)
        
        webViewActivityIndicatorView.hidesWhenStopped = true
        webViewActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(webViewActivityIndicatorView)

        // Center the activity indicator using Auto Layout
        webViewActivityIndicatorView.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        webViewActivityIndicatorView.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true

        self.customization()
    }
    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        showFile()
    }
    
    //MARK: Methods
    func customization() {
//        let resumeIcon = UIImage.init(named: "resume")?.withRenderingMode(.automatic)
//        let resumeBtn = UIBarButtonItem.init(image: resumeIcon!, style: .plain, target: self, action: #selector(self.download(_:)))
//        self.navigationItem.rightBarButtonItems?.append(resumeBtn)
    }
    
    func showFile() {
        webViewActivityIndicatorView.startAnimating()
        let fileName = "\(melkDetailAttachment!.attachId!)\(melkDetailAttachment!.fileExtension!)"
        
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        
        let fileUrl = documentsPath.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileUrl!.path) {
            
            let req1 = NSURLRequest(url: fileUrl!)
            self.webView.load(req1 as URLRequest)
            webViewActivityIndicatorView.stopAnimating()

        } else {
            fetchAgendaFile(fileUrl: fileUrl!)
            
        }
    }
    
    @IBAction func download(_ sender: Any) {
        resumeDownload()
    }
    
    func resumeDownload() {
        let fileName = "\(melkDetailAttachment!.attachId!)\(melkDetailAttachment!.fileExtension!)"
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        let fileUrl = documentsPath.appendingPathComponent(fileName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileUrl!.path){
            do {
                try fileManager.removeItem(at: fileUrl!)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
        
        fetchAgendaFile(fileUrl: fileUrl!, resume: true)
    }
    
    
    func fetchAgendaFile(fileUrl : URL, resume: Bool = false) -> Void {
        var request = URLRequest(url: URL(string: "\(BASE_URL)/melks/detail/attachments/\(melkDetailAttachment!.attachId!)")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(currentUser!.accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        downloadTask = session.downloadTask(with: request)
        downloadTask?.resume()
        self.downloadProgressView?.setProgress(0)
        self.downloadProgressView?.isHidden = false
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            var fileName = "\(melkDetailAttachment!.attachId!)\(melkDetailAttachment!.fileExtension!)"
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                print("PDF file saved at \(destinationURL)")
                
                let req1 = NSURLRequest(url: destinationURL)
                self.webView.load(req1 as URLRequest)
                
                DispatchQueue.main.async {
                    self.downloadProgressView?.isHidden = true//.removeFromSuperview()
                    self.webViewActivityIndicatorView.stopAnimating()
                }
            } catch {
                print("Error moving file: \(error)")
            }
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgressView?.setProgress(progress)
            
            print("progress: \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let httpResponse = task.response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            print("Status Code: \(statusCode)")
            
            // You can now use the statusCode as needed
            if statusCode == 200 {
                // Handle success
            } else {
                // Handle errors based on status code
            }
        }
        if let error = error {
            print("urlSession: \(String(describing: error))")
            DispatchQueue.main.sync {
                showAlert(title: "توجه!!", message: "فایل موردنظر یافت نشد!")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Handle the error and display a message to the user
        print("Web view error: \(error.localizedDescription)")
        
        showAlert(title: "توجه!!", message: "فایل موردنظر یافت نشد!")
    }


}


