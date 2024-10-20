db.fighters.find({ "league": "NBA" });
db.fighters.find().sort({ "wins": -1 }).limit(1);
db.weapons.find().sort({ "used_count": -1 }).limit(1);
db.environments.find().sort({ "fights_count": -1 }).limit(1);
db.fights.find({ "ai_robot_used": true });
