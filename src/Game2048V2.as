package
{
	import flash.display.Sprite;
	
	[SWF(width="550", height="400", frameRate="45")]
	public class Game2048V2 extends Sprite
	{
		public function Game2048V2()
		{
			addChild(new MainScene());
		}
	}
}