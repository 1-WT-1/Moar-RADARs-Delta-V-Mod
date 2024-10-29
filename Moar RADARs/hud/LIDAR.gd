extends "res://hud/LIDAR.gd"

func connectToShip():
	ship = reader.getShip()
	if Tool.claim(ship):
		type = ship.getLidarType()
		beams = [{"mask":lidarLightMask, "error":0, "response":1}]
		steps = 360
		coneSweep = false
		speedAdjust = true
		randomSweep = false
		doppler = true
		match type:
			"SYSTEM_LIDAR_OPA":
				steps = 1440
				doppler = false
				speedAdjust = false
				randomSweep = true
			"SYSTEM_RADAR_OPA":	
				doppler = false
				steps = 1440
				speedAdjust = false
				randomSweep = true
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":25.0, "response":0.5}]
			"SYSTEM_RADAR_OPA_DOPPLER":
				doppler = true
				steps = 1440
				speedAdjust = false
				randomSweep = true
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":25.0, "response":0.5}]
			"SYSTEM_LIDAR_RADAR":
				doppler = false
				steps = 1440
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":100.0, "response":0.2}]
			"SYSTEM_LIDAR_DOPPLER_CONE":
				steps = 720
				coneSweep = true
			"SYSTEM_RADAR_CONE":
				doppler = false
				steps = 720
				coneSweep = true
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":25.0, "response":0.5}]
			"SYSTEM_LIDAR_DOPPLER_HIRES":
				steps = 1440
			"SYSTEM_RADAR_HYBRID":
				steps = 1440
				doppler = false
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":0, "response":1}]
			"SYSTEM_RADAR_DOPPLER":
				doppler = true
				beams = [{"mask":lidarRadarMask, "error":0, "response":1}, {"mask":lidarLightMask, "error":90.0, "response":0.5}]
			"SYSTEM_LIDAR_DOPPLER":
				pass
				
		if (scanner or ship.lidar == null):
			ship.lidar = self
			dataNode = self
			recast.clear()
			if not data or data.size() != steps:
				data = PoolVector3Array()
				rayData = PoolVector3Array()
				astroBlockData = PoolRealArray()
				data.resize(steps)
				rayData.resize(steps)
				astroBlockData.resize(steps)
				
			
			if not ship.is_connected("shipPowerToggle", self, "shipPowered"):
				ship.connect("shipPowerToggle", self, "shipPowered")
		else:
			dataNode = ship.lidar
		field = ship.get_parent()
		onSetup()
		Tool.release(ship)
