//
//  ArchiveViewController.swift
//  WebArchives
//
//  Created by Yuumi Yoshida on 2019/02/02.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import UIKit
import WebKit

class ArchiveViewController: UIViewController, WKNavigationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    var urlString: String?
    let backend = Backend()
    let categories = ["記事", "Code", "Wine", "Art"]
    var hiddenCategoryPicker = true
    var heightRatio: Double = 1.0
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        saveButton.isEnabled = false
        categoryPicker.delegate = self
        categoryPicker.isHidden = hiddenCategoryPicker
        categoryText.delegate = self

         if let url = urlString {
            print("------ \(url)")
            backend.authorize(self) {
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                self.webView.load(URLRequest(url: URL(string: url)!))
            }
        }
    }
    
    @IBAction func pushCanceButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func pushSaveButton(_ sender: Any) {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false

        let (pdfPath, thumbData) = self.savePage(heightRatio)
        print("-- Upload PDF")
        self.backend.uploadPdf(path: pdfPath, complete: {pdfName in
            let data: [String : Any] = [
                "title": self.titleText.text ?? "",
                "category": self.categoryText.text ?? "",
                "url": self.webView.url?.absoluteString ?? "",
                "thumb": thumbData,
                "pdf": pdfName,
                "created_at": Date()]
            self.backend.addArticle(data: data, complete: {articleId in
                print("-- Save completed \(articleId)")
                self.loadingIndicator.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
           })
        })
    }
    
    @IBAction func clickCategoryText(_ sender: Any) {
        hiddenCategoryPicker = !hiddenCategoryPicker
        categoryPicker.isHidden = hiddenCategoryPicker
        webView.isHidden = !hiddenCategoryPicker
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // force read-only to categoryText
        return textField != categoryText
    }
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        titleText.text = webView.title ?? ""

        webView.evaluateJavaScript(
            "document.body.scrollHeight / document.body.scrollWidth",
            completionHandler: { (result, _) -> Void in
                if let heightRatio = result as? Double {
                    self.saveButton.isEnabled = true
                    self.heightRatio = heightRatio
                }
            }
        )
    }

    func savePage(_ heightRatio: Double) -> (String, Data) {
        let A4_WIDTH = 595.2
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: A4_WIDTH, height: A4_WIDTH * heightRatio)
        let printable = page.insetBy(dx: 0, dy: 0)
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        let pdfPath = "\(NSTemporaryDirectory())web.pdf"
        pdfData.write(toFile: pdfPath, atomically: true)
        
        UIGraphicsBeginImageContextWithOptions(self.webView.bounds.size, true, 0)
        self.webView.drawHierarchy(in: self.webView.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        let rsizeHeight = 256.0
        let aspectScale = snapshotImage.size.width / snapshotImage.size.height
        let resizedSize = CGSize(width: rsizeHeight * Double(aspectScale), height: rsizeHeight)
        UIGraphicsBeginImageContextWithOptions(resizedSize, true, 1.0)
        snapshotImage.draw(in: CGRect(origin: .zero, size: resizedSize))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        let thumbData = thumbImage.pngData()!
        
        return (pdfPath, thumbData)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryText.text = categories[row]
    }
    
}

