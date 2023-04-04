extends Node
# Harmonic Motion springs
# (OLD : http://www.digitalsalmon.co.uk/simple-harmonic-motion)
# https://digitalsalmon.co.uk/#/blog/simple-harmonic-motion

const epsilon = 0.0001
var _last_delta := 0.016666



var _damped_spring_motion_params = {
	dampingRatio = 0.0,
	angularFrequency = 0.0,
	PosPosCoef = 0.0,
	PosVelCoef = 0.0,
	VelPosCoef = 0.0,
	VelVelCoef = 0.0,
}

var _carry_velocity := Vector3.ZERO


func initialise( dampingRatio: float = 0.0, angularFrequency: float = 0.0  ):
	_damped_spring_motion_params = _calc_damped_spring_motion_params( dampingRatio, angularFrequency)


func _reinit(delta : float) -> void:
	# re-call initialise if delta has changed
	if not Util.near( delta, _last_delta, 0.018 ):
		# TODO: adjust near threshold/remove debug warning:
		push_warning("harmonic motion._reinit %0.3f %0.3f (difference %0.3f)"%[delta, _last_delta, abs(_last_delta - delta)])
		_last_delta = delta
		initialise( _damped_spring_motion_params.dampingRatio, _damped_spring_motion_params.angularFrequency )


# float form
func calculate( state: float = 0.0, targetState: float = 0.0, delta: float = 0.016666 ) -> float:
	_reinit(delta)
	var oldPos : float = state - targetState # update in equilibrium relative space
	var oldVel : float = _carry_velocity.x

	state = oldPos * _damped_spring_motion_params.PosPosCoef + oldVel * _damped_spring_motion_params.PosVelCoef + targetState
	_carry_velocity.x = oldPos * _damped_spring_motion_params.VelPosCoef + oldVel * _damped_spring_motion_params.VelVelCoef
	return state


# Vector2 form
func calculate_v2( state: Vector2 = Vector2.ZERO, targetState: Vector2 = Vector2.ZERO, delta: float = 0.016666 ) -> Vector2:
	_reinit(delta)
	var oldPos = state - targetState # update in equilibrium relative space
	var oldVel = Vector2(_carry_velocity.x, _carry_velocity.y)

	state = oldPos * _damped_spring_motion_params.PosPosCoef + oldVel * _damped_spring_motion_params.PosVelCoef + targetState
	var c = oldPos * _damped_spring_motion_params.VelPosCoef + oldVel * _damped_spring_motion_params.VelVelCoef
	_carry_velocity.x = c.x
	_carry_velocity.y = c.y
	return state


# Vector3 form
func calculate_v3(state: Vector3 = Vector3.ZERO, targetState: Vector3 = Vector3.ZERO, delta: float = 0.016666 ) -> Vector3:
	_reinit(delta)
	var oldPos = state - targetState # update in equilibrium relative space
	var oldVel = _carry_velocity

	state = oldPos * _damped_spring_motion_params.PosPosCoef + oldVel * _damped_spring_motion_params.PosVelCoef + targetState
	var c = oldPos * _damped_spring_motion_params.VelPosCoef + oldVel * _damped_spring_motion_params.VelVelCoef
	_carry_velocity.x = c.x
	_carry_velocity.y = c.y
	_carry_velocity.z = c.z
	return state


func _calc_damped_spring_motion_params( dampingRatio: float = 0.0, angularFrequency: float = 0.0  ):
	# force values into legal range
	if dampingRatio < 0.0: dampingRatio = 0.0
	if angularFrequency < 0.0: angularFrequency = 0.0
	
	var d = _damped_spring_motion_params.duplicate()
	d.dampingRatio = dampingRatio
	d.angularFrequency = angularFrequency

	# if there is no angular frequency,
	# the spring will not move and we can return identity
	if angularFrequency < epsilon :
#		var d = _damped_spring_motion_params.duplicate(true)
		d.PosPosCoef = 1.0
		d.PosVelCoef = 0.0
		d.VelPosCoef = 0.0
		d.VelVelCoef = 1.0
		return d
		
	if dampingRatio > 1.0 + epsilon:
		# over-damped
		var za = -angularFrequency * dampingRatio
		var zb = angularFrequency * sqrt( dampingRatio * dampingRatio - 1.0 )
		var z1 = za - zb
		var z2 = za + zb
	
		var e1 = exp(z1 * _last_delta)
		var e2 = exp(z2 * _last_delta)
		
		var invTwoZb = 1.0/(2.0 * zb)
		
		var e1_Over_TwoZb = e1 * invTwoZb
		var e2_Over_TwoZb = e2 * invTwoZb
		
		var z1e1_Over_TwoZb = z1 * e1_Over_TwoZb
		var z2e2_Over_TwoZb = z2 * e2_Over_TwoZb
		
#		var d = _damped_spring_motion_params.duplicate()
		d.PosPosCoef = e1_Over_TwoZb * z2 - z2e2_Over_TwoZb + e2
		d.PosVelCoef = -e1_Over_TwoZb + e2_Over_TwoZb
		d.VelPosCoef = (z1e1_Over_TwoZb - z2e2_Over_TwoZb + e2) * z2
		d.VelVelCoef = -z1e1_Over_TwoZb + z2e2_Over_TwoZb
		return d
		
	if dampingRatio < 1.0 - epsilon:
		# under-damped
		var omegaZeta = angularFrequency * dampingRatio
		var alpha = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)
		
		var expTerm = exp(-omegaZeta * _last_delta)
		var cosTerm = cos(alpha * _last_delta)
		var sinTerm = sin(alpha * _last_delta)
		
		var invAlpha = 1.0 / alpha
		
		var expSin = expTerm * sinTerm
		var expCos = expTerm * cosTerm
		var expOmegaZetaSin_Over_Alpha = expTerm * omegaZeta * sinTerm * invAlpha
		
#		var d = _damped_spring_motion_params.duplicate()
		d.PosPosCoef = expCos + expOmegaZetaSin_Over_Alpha
		d.PosVelCoef = expSin * invAlpha
		d.VelPosCoef = -expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha
		d.VelVelCoef = expCos - expOmegaZetaSin_Over_Alpha
		return d

	else:
		# critically damped
		var expTerm = exp(-angularFrequency * _last_delta)
		var timeExp = _last_delta * expTerm
		var timeExpFreq = timeExp * angularFrequency
		
#		var d = _damped_spring_motion_params.duplicate()
		d.PosPosCoef = timeExpFreq + expTerm
		d.PosVelCoef = timeExp
		d.VelPosCoef = -angularFrequency * timeExpFreq
		d.VelVelCoef = -timeExpFreq + expTerm
		return d
