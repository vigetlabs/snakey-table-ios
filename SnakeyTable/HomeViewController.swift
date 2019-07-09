import UIKit

class PlaceCell: SnakeyTableCell {
    @IBOutlet weak var name: UILabel!
}

class HomeViewController: UITableViewController {

    // MARK: - Properties

    var shouldAnimateCells = true
    let places: [String] = [
        "Falls Church, VA",
        "Durham, NC",
        "Boulder, CO",
        "Redwood City, CA",
        "Austin, TX",
        "Kansas City, KS",
        "Chattanooga, TN",
        "Charleston, SC"
    ]

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldAnimateCells = false
    }

    private func setupTableView() {
        tableView.register(PlaceCell.self, forCellReuseIdentifier: "PlaceCell")
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
        cell.name.text = places[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if shouldAnimateCells, let placeCell = cell as? PlaceCell {
            placeCell.render(indexPath.row, last: places.count)
            placeCell.animate(position: indexPath.row)
        }
    }

}
