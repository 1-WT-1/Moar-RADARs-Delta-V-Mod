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

func onSetup():
	if reader.has_method("registerSubsystem"):
		reader.registerSubsystem(
			"TUNE_AUDIO_LIDAR", 
			{
				"type":"bool", 
				"default":true, 
				"current":getBleepSound(ship), 
				"unit":"%", 
				"testProtocol":"lidar", 
				"subsystem":type, 
			})

		if speedAdjust:
			reader.registerSubsystem(
				"TUNE_LIDAR_SPEED", 
				{
					"type":"float", 
					"default":100.0, 
					"min":25.0, 
					"max":400.0, 
					"step":25.0, 
					"current":getSweepVelocity(ship) * 100, 
					"unit":"%", 
					"testProtocol":"lidar", 
					"subsystem":type, 
				})
		if coneSweep:
			reader.registerSubsystem(
				"TUNE_LIDAR_CONE", 
				{
					"type":"float", 
					"default":30.0, 
					"min":5.0, 
					"max":270.0, 
					"step":5.0, 
					"current":getConeAngle(ship), 
					"unit":"deg", 
					"testProtocol":"lidar", 
					"subsystem":type, 
				})
			reader.registerSubsystem(
				"TUNE_LIDAR_CONE_FOCUS", 
				{
					"type":"float", 
					"default":0.0, 
					"min": -10.0, 
					"max":10.0, 
					"step":1.0, 
					"current":getConeFocus(ship), 
					"unit":"", 
					"testProtocol":"lidar", 
					"subsystem":type, 
				})
	doBleep = getBleepSound(ship)
