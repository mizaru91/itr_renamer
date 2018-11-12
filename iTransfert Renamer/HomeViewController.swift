//
//  ViewController.swift
//  iTransfert Renamer
//
//  Created by Mizaru on 01/11/2018.
//  Copyright © 2018 France Televisions. All rights reserved.
//

import Cocoa
//import Foundation

class HomeViewController: NSViewController, NSPopoverDelegate, NSComboBoxDelegate, NSTextFieldDelegate {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var staticLabel: NSTextField!
    @IBOutlet weak var dragView: DragView!
    @IBOutlet weak var titleTxt: NSTextField!
    @IBOutlet weak var versionMenu: NSPopUpButton!
    @IBOutlet weak var redaMenu: NSComboBox!
    @IBOutlet weak var jriTxt: NSTextField!
    @IBOutlet weak var editionMenu: NSComboBox!
    @IBOutlet weak var lieuMenu: NSTextField!
    @IBOutlet weak var showFilepath: NSTextField!
    @IBOutlet weak var showSanitisedName: NSTextField!
    @IBOutlet weak var renameFileButton: NSButton!
    var filepath: NSURL?
    var titleSelected: String?
    var redaSelected: String?
    var jriSelected: String?
    var lieuSelected: String?
    
    @IBAction func resetToDefaultForm(_ sender: NSButton) {
        titleTxt.stringValue = ""
        redaMenu.stringValue = ""
        jriTxt.stringValue = ""
        editionMenu.stringValue = ""
        lieuMenu.stringValue = ""
        filepath = nil
        showFilepath.stringValue = ""
        showSanitisedName.stringValue = ""
        renameFileButton.isEnabled = false
    }
    
    // Ecoute si l'utilisateur fait sélection dans la liste déroulante des champs Version, rédaction et Edition
    @IBAction func SelectionDidChange(_ sender: Any) {
        getUserInputs()
    }
    
    let toUppercaseASCIINoSpaces = StringTransform(rawValue: "Latin-ASCII; Upper; [:Separator:] Remove; [:Punctuation:] Remove; [:Mark:] Remove;[:Symbol:] Remove;")
    
    @IBAction func renameFile(_ sender: NSButton) {
        
        // On récupère la valeur du champs TITRE
        var title: String? = titleTxt.stringValue
        if titleTxt.stringValue.isEmpty {
            title = "NULL"
        }
        titleSelected = sanitise(texte: title)
        
        // On récupère la valeur du champs JRI
        var jri: String? = jriTxt.stringValue
        if jriTxt.stringValue.isEmpty {
            jri = "NULL"
        }
        jriSelected = sanitise(texte: jri)
        
        // On récupère la valeur du champs JRI
        var lieu: String? = lieuMenu.stringValue
        if lieuMenu.stringValue.isEmpty {
            lieu = "NULL"
        }
        lieuSelected = sanitise(texte: lieu)
        
        // On récupère la valeur du menu VERSION
        var vers: String? = versionMenu.titleOfSelectedItem
        if versionMenu.titleOfSelectedItem!.isEmpty {
            vers = "NULL"
        }
        let versionSelected: String? = sanitise(texte: vers)
        
        // On récupère la valeur du menu REDACTION
        var redac: String? = redaMenu.stringValue
        if redaMenu.stringValue.isEmpty {
                redac = "NULL"
        }
        switch redac {
            case "France2": redac = "F2"
            case "France3": redac = "F3"
            case "FranceInfo": redac = "FI"
            default: redac = redaMenu.stringValue
        }
        redaSelected = sanitise(texte: redac)
        
        // On récupère la valeur du menu EDITION
        var edit: String? = editionMenu.stringValue
        if editionMenu.stringValue.isEmpty {
            edit = "NULL"
        }
        let editSelected: String? = sanitise(texte: edit)
        
        // On teste la présence d'un fichier dropé avant de travailler dessus.
        if filepath != nil {
            renameFileButton.isEnabled = true
            /*:     Phase de renommage du fichier, si le chemin du fichier est connu
             Create a FileManager instance                                          */
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filepath!.path!){
                do {
                    // Nomenclature = F3_12-13_V1_MON_TITRE_CHRISTOPH_KAR_COMBS_LA_VILLE___135K
                    // Extraction du chemin
                    let path: String = filepath!.deletingLastPathComponent!.absoluteString
                    // Extrraction de l'extension
                    let ext: String = filepath!.pathExtension!
                    let renamedpath: String = ("\(path)\(redaSelected!)_\(editSelected!)_\(versionSelected!)_\(titleSelected!)_\(jriSelected!)_\(lieuSelected!)__\(infoAbout(url: filepath as! URL)).\(ext)")
                    try fileManager.moveItem(at: filepath as! URL, to: URL(string : renamedpath)!)
                    renameFileButton.isEnabled = false
                } catch let error as NSError {
                    showModal(alerte: "\(error)")
                }
        } else {
                showModal(alerte: "Fichier introuvable, merci de vérifier le chemin: \(filepath!.path!)")
            //NSLog(self.filepath!.absoluteString!)
            }
        } else {
            //renameFileButton.isEnabled = false
            showModal(alerte: "Merci de sélectionner un fichier.")
        }
    }

    // Mes fonctions
    func sanitise(texte: String?) -> String {
        let sanitised: String? = texte!.applyingTransform(toUppercaseASCIINoSpaces, reverse: false)!
            .applyingTransform(.stripCombiningMarks, reverse: false)!
            .applyingTransform(.stripDiacritics, reverse: false)!
        NSLog(sanitised!)
        return sanitised!
    }
    func showModal(alerte: String?){
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Erreur"
        alert.informativeText = alerte!
        alert.runModal()
    }
    // Fonction de récupération des informations techniques du fichier
    func infoAbout(url: URL) -> String {
        // 1
        let fileManager = FileManager.default
        var imgSizeInMB: String?
        // 2
        do {
            // 3
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            //var report: [String] = ["\(url.path)", ""]
            var report: String = url.path
            // 4
            for (key, value) in attributes {
                // ignore NSFileExtendedAttributes as it is a messy dictionary
                if key.rawValue == "NSFileExtendedAttributes" { continue }
                // Filtre juste sur la taille de fichier, les autres attributs ne sont pas util
                /*: NSFileOwnerAccountName:     mizaru
                NSFilePosixPermissions:     420
                NSFileSystemNumber:     16777223
                NSFileReferenceCount:     1
                NSFileSystemFileNumber:     1909228
                NSFileCreationDate:     2018-10-05 19:05:15 +0000
                NSFileHFSTypeCode:     0
                NSFileType:     NSFileTypeRegular
                NSFileGroupOwnerAccountName:     staff
                NSFileGroupOwnerAccountID:     20
                NSFileHFSCreatorCode:     0
                NSFileModificationDate:     2018-10-05 19:05:15 +0000
                NSFileSize:     137895
                NSFileExtensionHidden:     1
                NSFileOwnerAccountID:     503 */
                if key.rawValue == "NSFileSize" {
                    imgSizeInMB = format(bytes: Double(value as! Int))
                    //print("Taille du fichier:\(imgSizeInMB)")
                    //report.append("\(key.rawValue):\t \(value)")
                }
            }
            // 5
            //return report.joined(separator: "\n")
            return imgSizeInMB!
        } catch {
            // 6
            return "No information available for \(url.path)"
        }
    }
    

    func getUserInputs() {
        // On récupère la valeur du champs TITRE
        var title: String? = titleTxt.stringValue
        if titleTxt.stringValue.isEmpty {
            title = "NA"
        }
        titleSelected = sanitise(texte: title)
        
        // On récupère la valeur du champs JRI
        var jri: String? = jriTxt.stringValue
        if jriTxt.stringValue.isEmpty {
            jri = "NA"
        }
        jriSelected = sanitise(texte: jri)
        
        // On récupère la valeur du champs JRI
        var lieu: String? = lieuMenu.stringValue
        if lieuMenu.stringValue.isEmpty {
            lieu = "NA"
        }
        lieuSelected = sanitise(texte: lieu)
        
        // On récupère la valeur du menu VERSION
        var vers: String? = versionMenu.titleOfSelectedItem
        if versionMenu.titleOfSelectedItem!.isEmpty {
            vers = "NA"
        }
        let versionSelected: String? = sanitise(texte: vers)
        
        // On récupère la valeur du menu REDACTION
        var redac: String? = redaMenu.stringValue
        if redaMenu.stringValue.isEmpty {
            redac = "NA"
        }
        switch redac {
            case "France2": redac = "F2"
            case "France3": redac = "F3"
            case "FranceInfo": redac = "FI"
            default: redac = redaMenu.stringValue
        }
        redaSelected = sanitise(texte: redac)
        
        // On récupère la valeur du menu EDITION
        var edit: String? = editionMenu.stringValue
        if editionMenu.stringValue.isEmpty {
            edit = "NA"
        }
        let editSelected: String? = sanitise(texte: edit)
        
        // On teste la présence d'un fichier dropé avant de travailler dessus.
        if filepath != nil {
            renameFileButton.isEnabled = true
            /*:     Phase de renommage du fichier, si le chemin du fichier est connu
             Create a FileManager instance                                          */
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filepath!.path!){
                do {
                    // Nomenclature = F3_12-13_V1_MON_TITRE_CHRISTOPH_KAR_COMBS_LA_VILLE___135K
                    // Extraction du chemin
                    let path: String = filepath!.deletingLastPathComponent!.absoluteString
                    // Extrraction de l'extension
                    let ext: String = filepath!.pathExtension!
                    let renamedpath: String = ("\(redaSelected!)_\(editSelected!)_\(versionSelected!)_\(titleSelected!)_\(jriSelected!)_\(lieuSelected!)__\(infoAbout(url: filepath as! URL)).\(ext)")
                    // On modifie la valeur du label pour afficher le nommage
                    showSanitisedName.stringValue = renamedpath
                } catch let error as NSError {
                    NSLog("\(error)")
                }
            } else {
                NSLog("Fichier introuvable, merci de vérifier le chemin: \(filepath!.path!)")
            }
        } else {
            renameFileButton.isEnabled = false
            NSLog("Merci de sélectionner un fichier.")
        }
    }
    // Ecoute si l'utilisateur fait une entrée manuelle dans le champs rédaction et Edition
    func comboBoxWillPopUp(_ notification: Notification) {
        getUserInputs()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        getUserInputs()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renameFileButton.isEnabled = false
        // Do any additional setup after loading the view.
        dragView.delegate = self
        // Combobox Rédaction
        versionMenu.removeAllItems()
        versionMenu.addItems(withTitles: ["V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"])
        // Combobox Rédaction
        redaMenu.removeAllItems()
        redaMenu.addItems(withObjectValues: ["France2", "France3", "FranceInfo"])
        // Combobox Edition
        editionMenu.removeAllItems()
        editionMenu.addItems(withObjectValues: ["12-13", "13h", "19-20", "20h", "Soir3", "Rushes", "Elements", "Internet", "Telematin", "Week-end", "Autre"])
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    //Calcul de la taille du fichier sélectionné
    func format(bytes: Double) -> String {
        guard bytes > 0 else {
            return "0 bytes"
        }
        // Adapted from http://stackoverflow.com/a/18650828
        let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        let k: Double = 1000
        let i = floor(log(bytes) / log(k))
        
        // Format number with thousands separator and everything below 1 GB with no decimal places.
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = i < 3 ? 0 : 1
        numberFormatter.numberStyle = .decimal
        
        let numberString = numberFormatter.string(from: NSNumber(value: bytes / pow(k, i))) ?? "Unknown"
        let suffix = suffixes[Int(i)]
        return "\(numberString)\(suffix)"
    }

}

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let strongSelf = self else {
            return nil
        }
        return strongSelf.isEmpty ? nil : strongSelf
    }
}
extension HomeViewController: DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL) {
        self.filepath = URL
        self.showFilepath.stringValue = URL.path ?? "Désolé, information de chemin, non disponible"
        self.renameFileButton.isEnabled = true
        //print(self.filepath ?? "Désolé, information de chemin, non disponible")
    }
}
//extension StringTransform {
//    static let toUppercaseASCIINoSpaces = StringTransform(rawValue: "Latin-ASCII; Lower; [:Separator:] Remove;")
//}
