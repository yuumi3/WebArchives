//
//  DetailViewController.swift
//  WebArchives
//
//  Created by Yuumi Yoshida on 2019/02/01.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import UIKit
import PDFKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var categoryLable: UILabel!
    @IBOutlet weak var createdAtLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var pdfUIView: UIView!

    let backend = Backend()
    var pdfView = PDFView()
    var pdfLoaclPath = ""
    var detailItem: [String : Any]? {
        didSet {
            configureView()
        }
    }

    func configureView() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let detail = detailItem, let categoryLable = categoryLable {
            categoryLable.text = detail["category"] as? String
            titleLable.text    = detail["title"] as? String
            urlText.text       = detail["url"] as? String
            createdAtLable.text = dateFormat.string(from: detail["created_at"] as! Date)
            self.navigationItem.title = detail["title"] as? String
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            backend.downloadPdf(pdfName: detail["pdf"] as! String) { (path) in
                print("--- downloadPdf \(path)")
                self.pdfLoaclPath = path
                self.setPDFView()
                self.view.addSubview(self.pdfView)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        urlText.delegate = self
        categoryLable.text  = ""
        titleLable.text     = ""
        createdAtLable.text = ""
        urlText.text = ""
        
        configureView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if detailItem != nil {
            self.pdfView.removeFromSuperview()
            setPDFView()
            self.view.addSubview(self.pdfView)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

    private func setPDFView() {
        self.pdfView = PDFView(frame: self.pdfUIView.frame)
        self.pdfView.document = PDFDocument(url: URL(fileURLWithPath: self.pdfLoaclPath))
        self.pdfView.backgroundColor = .white
        self.pdfView.autoScales = true
    }
}

