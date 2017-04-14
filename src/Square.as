package
{
	import com.lion.managers.interfaces.IPoolItem;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;

	public class Square extends Sprite implements IPoolItem
	{
		private var skin:SquareSkin;
		
		public var isMegered:Boolean = false;
		public var isRemoved:Boolean = false;
		public var num:int = 2;
		public var len:int = 80;
		public var position:Point;
		
		private var colors:Array = [0xD9ADAD, 0xE6B789, 0xF2C261, 0xFFCC00, 0xFF9965, 0xFF9932, 0xFF9900, 0xFF6602, 0xFF3300, 0xCC3200, 0xCC0000, 0x9A0000];
		private var values:Array = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096];
		private var txt:TextField;
		private var bg:MovieClip;
		
		public function Square()
		{
			skin = new SquareSkin();
			addChild(skin);
			txt = skin.txt;
			bg = skin.bg;
			bg.removeChildAt(0);
			update();
		}
		public function update():void
		{
			if(num)
			{
				for (var i:int = values.length - 1; i > -1 ; i--) 
					if(num >= values[i])
						break;
				
				bg.graphics.clear();
				bg.graphics.beginFill(colors[i]);
				bg.graphics.drawRoundRect(0, 0, len, len, 15, 15);
				bg.graphics.endFill();
				
				txt.text = num.toString();
			}
			else
				txt.text = "";
		}
		public function dispose():void
		{
			
		}
		public function reset():void
		{
			isMegered = false;
			isRemoved = false;
			alpha = 1;
			num = 2;//Math.pow(2, 1 + int(Math.random() * 3));
			update();
			position = null;
		}
	}
}