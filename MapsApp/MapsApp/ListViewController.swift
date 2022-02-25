//
//  ListViewController.swift
//  MapsApp
//
//  Created by Macbook on 11.02.2022.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenYerIsim = ""
    var secilenYerId :UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(artiButonuTiklandi))

        VerileriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(VerileriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
    
    
    @objc func VerileriAl () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        
        do {
            let sonuclar = try context.fetch(request)
            if sonuclar.count > 0 {
                
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let isim = sonuc.value(forKey: "isim") as? String {
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch{
            print("hata var")
        }
    }
    
    @objc func artiButonuTiklandi() {
        secilenYerIsim = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        cell.textLabel?.font = UIFont (name: "ArchitectsDaughter-Regular", size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsim = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.secilenIsim = secilenYerIsim
            destinationVC.secilenId = secilenYerId
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            let uuidString = idDizisi[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row] {
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                }catch {
                                    
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("hata")
            }
        }
    }

}
