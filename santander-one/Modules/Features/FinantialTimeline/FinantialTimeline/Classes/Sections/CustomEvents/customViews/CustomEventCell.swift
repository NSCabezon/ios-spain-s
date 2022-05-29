//
//  CustomEventCellTableViewCell.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 10/10/2019.
//

import UIKit

class CustomEventCell: UITableViewCell {
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .santanderText(type: .bold, with: 14)
        label.textColor = .lightBurgundy
        return label
    }()
    
    let eventDescription: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = .santanderText(type: .regular, with: 15)
        label.textColor = .greyishBrown
        return label
    }()
    
    let eventFrequency: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textAlignment = .right
        label.font = .santanderText(type: .regular, with: 14)
        label.textColor = .brownishGrey
        return label
    }()
    
    let accessoryCellView: UIImageView = {
        let view = UIImageView(image: UIImage(fromModuleWithName: "cellAccessory"))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configView()
    }
    
    func configView() {
        addSubview(accessoryCellView)
        accessoryCellView.translatesAutoresizingMaskIntoConstraints = false
        accessoryCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -17).isActive = true
        accessoryCellView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        accessoryCellView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        accessoryCellView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(eventFrequency)
        eventFrequency.translatesAutoresizingMaskIntoConstraints = false
        eventFrequency.trailingAnchor.constraint(equalTo: accessoryCellView.leadingAnchor, constant: -8).isActive = true
        eventFrequency.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        eventFrequency.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(eventDescription)
        eventDescription.translatesAutoresizingMaskIntoConstraints = false
        eventDescription.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        eventDescription.widthAnchor.constraint(lessThanOrEqualToConstant: 232).isActive = true
        eventDescription.trailingAnchor.constraint(equalTo: eventFrequency.leadingAnchor, constant: -18).isActive = true
        eventDescription.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(eventLabel)
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        eventLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 232).isActive = true
        eventLabel.bottomAnchor.constraint(equalTo: eventDescription.topAnchor, constant: 0).isActive = true
    }
    
    func configCell(withEvent event: PeriodicEvent) {
        eventLabel.text = event.title
        eventDescription.text = event.description
        switch event.frequency {
        case "00": eventFrequency.text = event.startDate.getDate(withFormat: .yyyyMMdd)?.string(format: .ddMMyyyy)
        case "01": eventFrequency.text = IBLocalizedString("timeline.newcustomeventSection.event.frequency.weekly")
        case "02": eventFrequency.text = IBLocalizedString("timeline.newcustomeventSection.event.frequency.twoweeks")
        case "03": eventFrequency.text = IBLocalizedString("timeline.newcustomeventSection.event.frequency.monthly")
        case "04": eventFrequency.text = IBLocalizedString("timeline.newcustomeventSection.event.frequency.annually")
        default:()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ? .sky30 : .white
    }

}
