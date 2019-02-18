//
//  Backend.swift
//  WebArchives
//
//  Created by Yuumi Yoshida on 2019/02/03.
//  Copyright © 2019年 Yuumi Yoshida. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

struct ArticleQueryOption {
    var orderColumn: String?
    var orderDescending: Bool?
    var category: String?
    
    func isFilled() -> Bool {
        return category != nil && orderColumn != nil && orderDescending != nil
    }
}

public class Backend {
    let providers: [FUIAuthProvider] = [
        FUIGoogleAuth()
    ]
    var authUI: FUIAuth!

    func authorize(_ viewController: UIViewController, complete: @escaping () -> Void) {
        authUI = FUIAuth.defaultAuthUI()
        authUI.delegate = viewController as? FUIAuthDelegate
        authUI.providers = providers
        authUI.isSignInWithEmailHidden = true
        checkLoggedIn(viewController: viewController, complete: complete)
    }
    
    func logout() {
        try! authUI.signOut()
    }
    
    func addArticle(data: [String:Any], complete: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("articles").addDocument(data: data) { error in
            if let err = error {
                print("-- Error adding document: \(err)")
            } else {
                complete(ref!.documentID)
            }
        }
    }
 
    func queryArticles(option: ArticleQueryOption, complete: @escaping ([DocumentSnapshot]) -> Void) {
        guard let orderColumn = option.orderColumn, let orderDescending = option.orderDescending else {
            print("!!! option is null")
            return
        }

        let db = Firestore.firestore()
        let articlesRef = db.collection("articles")
        var query = articlesRef.order(by: orderColumn, descending: orderDescending)
        if let category = option.category, category != "ALL" {
            query = query.whereField("category", isEqualTo: category)
        }

        query.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let query = querySnapshot {
                complete(query.documents)
            } else {
                print("--- ????")
            }
        }
    }
    
    func uploadPdf(path: String, complete: @escaping (String) -> Void) {
        let pdfName = "pdf/\(filenameByTime()).pdf"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let pdfRef = storageRef.child(pdfName)
        pdfRef.putFile(from: URL(fileURLWithPath: path), metadata: nil) {(metadata, error) in
            if let err = error {
                print("-- Error upload PDF: \(err)")
            } else {
                complete(pdfName)
            }
        }
    }

    func downloadPdf(pdfName: String, complete: @escaping (String) -> Void) {
        let path = NSTemporaryDirectory() + pdfName.dropFirst(4)
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let pdfRef = storageRef.child(pdfName)
        pdfRef.write(toFile: URL(fileURLWithPath: path), completion: { (_, error) in
             if let err = error {
                print("-- Error download PDF: \(err)")
            } else {
                complete(path)
            }
        })
    }

    private func checkLoggedIn(viewController: UIViewController, complete: @escaping () -> Void) {
        Auth.auth().addStateDidChangeListener{auth, user in
            if user != nil {
                complete()
            } else {
                print("-- Auth fail")
                let authViewController = self.authUI.authViewController()
                authViewController.navigationBar.topItem?.title  = "Login"
                viewController.present(authViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func filenameByTime() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmmss"
        return dateFormat.string(from: Date()) + "_" +
            String(format: "%04d", Int.random(in: 0..<10000))
    }

}
