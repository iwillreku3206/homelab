try {
	const status = rs.status();
	if (status.ok === 1) {
		print("Replica set already initialized: " + status.set);
	}
} catch (e) {
	if (e.codeName === "NotYetInitialized") {
		print("Replica set not initialized. Initializing...");
		rs.initiate({
			_id: "rs0",
			members: [{ _id: 0, host: "mongo.mongodb:27017" }]
		});
		print("Replica set initialization command sent.");
	} else {
		print("Unexpected error: " + e);
	}
}
