import UIKit

class GenericCollectionViewDataSource<T>: NSObject, UICollectionViewDataSource where T: CarouselItem {
    
    private(set) var sections = [[T]]()
    
    func setSections(_ sections: [[T]]) {
        self.sections = sections
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sections.count > section else {
            return 0
        }
        return sections[section].count
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let element = sections[indexPath.section][indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: element.identifier, for: indexPath)
        
        element.configure(cell: cell)
        
        return cell
    }
    
}
