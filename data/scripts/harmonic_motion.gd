extends Node
# Harmonic Motion
# https://digitalsalmon.co.uk/simple-harmonic-motion-an-alternative-to-continuous-lerp/

const epsilon = 0.0001
const sixtyfps_delta = 0.016666

#var velocity := 0.0

var DampenedSpringMotionParams = {
	# newPos = posPosCoef*oldPos + posVelCoef*oldVel
	# newVel = velPosCoef*oldPos + velVelCoef*oldVel
	PosPosCoef = 0.0,
	PosVelCoef = 0.0,
	VelPosCoef = 0.0,
	VelVelCoef = 0.0,
}


func calculate( state: float = 0.0, velocity: float = 0.0, targetState: float = 0.0, springMotionParams = DampenedSpringMotionParams ):
#func calculate( state: float = 0.0, targetState: float = 0.0, springMotionParams = DampenedSpringMotionParams ):
	var oldPos = state - targetState # update in equilibrium relative space
	var oldVel = velocity
	
	state = oldPos * springMotionParams.PosPosCoef + oldVel * springMotionParams.PosVelCoef + targetState
	velocity = oldPos * springMotionParams.VelPosCoef + oldVel * springMotionParams.VelVelCoef
	return [state, velocity]
	#return state


func CalcDampedSpringMotionParams( dampingRatio: float = 0.0, angularFrequency: float = 0.0  ):
	# force values into legal range
	if dampingRatio < 0.0: dampingRatio = 0.0
	if angularFrequency < 0.0: angularFrequency = 0.0
	
	# if there is no angular frequency,
	# the spring will not move and we can return identity
	if angularFrequency < epsilon :
		var d = DampenedSpringMotionParams.duplicate(true)
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
	
		var e1 = exp(z1 * sixtyfps_delta)
		var e2 = exp(z2 * sixtyfps_delta)
		
		var invTwoZb = 1.0/(2.0 * zb)
		
		var e1_Over_TwoZb = e1 * invTwoZb
		var e2_Over_TwoZb = e2 * invTwoZb
		
		var z1e1_Over_TwoZb = z1 * e1_Over_TwoZb
		var z2e2_Over_TwoZb = z2 * e2_Over_TwoZb
		
		var d = DampenedSpringMotionParams.duplicate()
		d.PosPosCoef = e1_Over_TwoZb * z2 - z2e2_Over_TwoZb + e2
		d.PosVelCoef = -e1_Over_TwoZb + e2_Over_TwoZb
		d.VelPosCoef = (z1e1_Over_TwoZb - z2e2_Over_TwoZb + e2) * z2
		d.VelVelCoef = -z1e1_Over_TwoZb + z2e2_Over_TwoZb
		return d
		
	if dampingRatio < 1.0 - epsilon:
		# under-damped
		var omegaZeta = angularFrequency * dampingRatio
		var alpha = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)
		
		var expTerm = exp(-omegaZeta * sixtyfps_delta)
		var cosTerm = cos(alpha * sixtyfps_delta)
		var sinTerm = sin(alpha * sixtyfps_delta)
		
		var invAlpha = 1.0 / alpha
		
		var expSin = expTerm * sinTerm
		var expCos = expTerm * cosTerm
		var expOmegaZetaSin_Over_Alpha = expTerm * omegaZeta * sinTerm * invAlpha
		
		var d = DampenedSpringMotionParams.duplicate()
		d.PosPosCoef = expCos + expOmegaZetaSin_Over_Alpha
		d.PosVelCoef = expSin * invAlpha
		d.VelPosCoef = -expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha
		d.VelVelCoef = expCos - expOmegaZetaSin_Over_Alpha
		return d

	else:
		# critically damped
		var expTerm = exp(-angularFrequency * sixtyfps_delta)
		var timeExp = sixtyfps_delta * expTerm
		var timeExpFreq = timeExp * angularFrequency
		
		var d = DampenedSpringMotionParams.duplicate()
		d.PosPosCoef = timeExpFreq + expTerm
		d.PosVelCoef = timeExp
		d.VelPosCoef = -angularFrequency * timeExpFreq
		d.VelVelCoef = -timeExpFreq + expTerm
		return d
