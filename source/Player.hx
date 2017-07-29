package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;

class Player extends FlxSprite
{
	public var speed:Float = 200;
	private var _sndStep:FlxSound;

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

		setSize(8, 14);
		offset.set(4, 2);
	}

	override public function update(elapsed:Float):Void
	{
		movement();
		super.update(elapsed);
	}

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
				if (_left)
					_ma -= 45;
				else if (_right)
					_ma += 45;

				facing = FlxObject.UP;
			}
			else if (_down)
			{
				_ma = 90;
				if (_left)
					_ma += 45;
				else if (_right)
					_ma -= 45;

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

			velocity.set(speed, 0);
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