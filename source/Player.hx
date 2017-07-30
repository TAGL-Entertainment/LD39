package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	// Sprint + stamina (tweakable)
	public var _walkingSpeed						: Float = 150;
	public var _sprintMultiplier					: Float = 1.5;
	public var _maxStamina							: Float = 2;
	public var _staminaRecoveryPerSecond			: Float = 1;
	public var _staminaSprintConsumptionPerSecond	: Float = 1;
	public var _delayAfterEmptyStamina 				: Float;
	
	// Sprint + stamina (non tweakable)
	public var _currentStamina						: Float;
	public var _isSprinting							: Bool = false;
	public var _canSprint							: Bool = true;

	// Bullying (tweakable)
	public var _minDistanceToBully 					: Int = 20;
	public var _bullyingCost						: Float = 0.5;
	public var _bullyingDelay						: Float = 0.5;
	public var _bullyForce							: Float = 300;
	
	// Bullying (non tweakable)
	public var _canBully							: Bool = true;
	public var _currentBullyCooldown 				: Float;
	
	// Polishing
	public var _stepSound							: FlxSound;
	
	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(AssetPaths.player__png, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);

		drag.x = drag.y = 1600;

		setSize(8, 6);
		offset.set(4, 10);
		
		_delayAfterEmptyStamina = _staminaRecoveryPerSecond * _maxStamina;
		_currentStamina = _maxStamina;
		
		_currentBullyCooldown = 0;
		
		FlxG.watch.add(this, "_currentStamina");
		FlxG.watch.add(this, "_isSprinting");
	}

	override public function update(elapsed:Float):Void
	{
		// Gestion du mouvement
		movement();
		
		// Gestion de la jauge de stamina (sprint)
		if (_isSprinting) {
			_currentStamina -= elapsed * _staminaSprintConsumptionPerSecond;
		} else {
			_currentStamina += elapsed * _staminaRecoveryPerSecond;
			if (_currentStamina > _maxStamina){
				_currentStamina = _maxStamina;
			}
		}
		
		// A bout de souffle, peut plus sprinter
		if (_currentStamina <= 0 && _canSprint) {
			_canSprint = false;
			new FlxTimer().start(_delayAfterEmptyStamina, StaminaRecoveryFinished);
		}
		
		// Update du cooldown du bullying
		if (_currentBullyCooldown > 0) {
			_currentBullyCooldown -= elapsed;
		}
		
		super.update(elapsed);
	}
	
	private function StaminaRecoveryFinished(Timer:FlxTimer):Void {
		_canSprint = true;
		_currentStamina = _maxStamina;
	}
	
	/**
	 * Gestion des mouvements et sprint
	 */
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;

		_up = FlxG.keys.anyPressed([UP, Z]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, Q]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
				
		_isSprinting = FlxG.keys.pressed.SPACE && _canSprint;

		if (_up && _down)
		{
			_up = _down = false;
		}

		if (_left && _right)
		{
			_left = _right = false;
		}

		if (_up || _down || _left || _right)
		{
			var _ma:Float = 0;

			if (_up)
			{
				_ma = -90;
				if (_left) {
					_ma -= 45;
				}
				else if (_right) {
					_ma += 45;
				}

				facing = FlxObject.UP;
			}
			else if (_down)
			{
				_ma = 90;
				if (_left) {
					_ma += 45;
				}
				else if (_right) {
					_ma -= 45;
				}

				facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				_ma = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				_ma = 0;
				facing = FlxObject.RIGHT;
			}

			velocity.set((_isSprinting ? _walkingSpeed * _sprintMultiplier : _walkingSpeed), 0);
			velocity.rotate(FlxPoint.weak(0, 0), _ma);

			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE)
			{
				switch (facing)
				{
					case FlxObject.LEFT, FlxObject.RIGHT:
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
	}
}