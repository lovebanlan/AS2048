package
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import com.lion.managers.ObjectPoolManager;
	import com.lion.managers.SecondManager;
	import com.lion.managers.interfaces.ISecondCountable;
	import com.lion.utils.StringUtil;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import avmplus.getQualifiedClassName;

	public class MainScene extends Sprite implements ISecondCountable
	{
		private var colNum:int = 4;
		private var rowNum:int = 4;
		private var space:int = 20;
		private var gap:int = 5;
		private var len:int = 50;
		
		private var needAnimate:Boolean = true;
		private var aniTime:Number = .3;
		private var aniSpeed:int = 600;
		private var squareMap:SquareMap;
		
		private var timeSpend:int = 0;
		private var score:int = 0;
		private var bar:Bar;
		
		private var timeLine:TimelineLite
		
		public function MainScene()
		{
			init();
		}
		
		public function updateSecond(second:int):void
		{
			timeSpend ++;
			bar.timeTxt.text = StringUtil.getTimeString(timeSpend);
		}
		private function addScore(num:int):void
		{
			score += num;
			bar.scoreTxt.text = score.toString();
		}
		private function init():void
		{
			for (var i:int = 0; i < rowNum; i++) 
			{
				for (var j:int = 0; j < colNum; j++) 
				{
					graphics.beginFill(0xeaeaea, .8);
					graphics.drawRect(space + gap + j * (gap + len), space + gap + i * (gap + len), len, len);
					graphics.endFill();
				}
			}
			
			graphics.lineStyle(1, 0xaaaaaa, .5);
			graphics.moveTo(space, space);
			graphics.lineTo(gap + space + (len + gap) * colNum, space);
			graphics.lineTo(gap + space + (len + gap) * colNum, gap + space + (len + gap) * rowNum);
			graphics.lineTo(space, gap + space + (len + gap) * rowNum);
			graphics.lineTo(space, space);
			
			initKey();
			
			squareMap = new SquareMap(rowNum, colNum);
			addRandomSquare();
			
			bar = new Bar();
			addChild(bar);
			bar.x = gap + space + (len + gap) * colNum + 30;
			bar.y = space + gap + gap;
			bar.restartBtn.addEventListener(MouseEvent.CLICK, restartHandler);
			
			SecondManager.getInstance().addItem(this);
			updateSecond(0);
			addScore(0);
		//	autoId = setInterval(autoPlay, 500);
		}
		private var autoId:int;
		protected function autoPlay():void
		{
			if(squareMap.checkAlive())
			{
				addScore(squareMap.moveSquares(int(1 + Math.random() * 4)));
				animateSquares();
			}
			else
				clearInterval(autoId);
		}
		protected function restartHandler(event:MouseEvent):void
		{
			var arr:Array = squareMap.getAllSquares();
			unableKey();
			if(timeLine)
				timeLine.kill();
			for (var i:int = 0; i < arr.length; i++) 
			{
				ObjectPoolManager.getInstance().returnItem(arr[i]);
				if(arr[i].stage)
					removeChild(arr[i]);
			}
			
			squareMap.resetMap();
			timeSpend = 0;
			score = 0;
			
			SecondManager.getInstance().addItem(this);
			updateSecond(0);
			addScore(0);
			
			addRandomSquare();
			initKey();
		}
		
		private function initKey():void
		{
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keydownHandler);
		}
		private function unableKey():void
		{
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN, keydownHandler);
		}
		protected function keydownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP: 		addScore(squareMap.moveSquares(1));	animateSquares();	break;
				case Keyboard.DOWN:		addScore(squareMap.moveSquares(2));	animateSquares();	break;
				case Keyboard.LEFT:		addScore(squareMap.moveSquares(3));	animateSquares();	break;
				case Keyboard.RIGHT:	addScore(squareMap.moveSquares(4));	animateSquares();	break;
			}
		}
		
		private function animateSquares():void
		{
			if(!squareMap.anyChange)
				return;
			unableKey();
			var arr:Array = squareMap.getAllSquares();
			if(needAnimate)
			{
				timeLine = new TimelineLite({onComplete:animateOver, onCompleteParams:[arr]});
				for (var i:int = 0; i < arr.length; i++) 
				{
					var square:Square = arr[i];
					var newPt:Point = getPositionByIndexes(square.position.y, square.position.x);
					//				if(newPt.x == square.x && newPt.y == square.y)
					//					return;
					square.alpha = 1;
					//				var time:Number = Point.distance(newPt, new Point(square.x, square.y)) / aniSpeed;
					if(square.isRemoved)
					{
						timeLine.insert(TweenLite.to(square, aniTime, {x:newPt.x, y:newPt.y}));
					}
					else
					{
						timeLine.insert(TweenLite.to(square, aniTime, {x:newPt.x, y:newPt.y}));
					}
				}
				timeLine.play();
			}
			else
			{
				for (i = 0; i < arr.length; i++) 
				{
					square = arr[i];
					newPt = getPositionByIndexes(square.position.y, square.position.x);
					square.alpha = 1;
					square.x = newPt.x;
					square.y = newPt.y;
				}
				
				animateOver(arr);
			}
		}
		private function animateOver(arr:Array):void
		{
			squareMap.updateSquares();
			squareMap.resetMap();
			
			for (var i:int = 0; i < arr.length; i++) 
			{
				if(arr[i].isRemoved)
				{
					removeChild(arr[i]);
					returnSquare(arr[i]);
				}
				else
				{
					arr[i].isMegered = false;
					squareMap.setSquare(arr[i]);
				}
			}
			
			addRandomSquare();
			if(!squareMap.checkAlive())
			{
				trace("dead");
				
				SecondManager.getInstance().removeItem(this);
				return;
			}
			initKey();
		}
		private function addRandomSquare():void
		{
			var square:Square = getRandomSquare();
			if(!square)
				return;
			addChild(square);
			squareMap.setSquare(square);
			var spt:Point = getPositionByIndexes(square.position.y, square.position.x);
			square.x = spt.x;
			square.y = spt.y;
			square.width = len;
			square.height = len;
			TweenLite.from(square, aniTime, {alpha:0});
		}
		private function getPositionByIndexes(row:int, col:int):Point
		{
			var pt:Point = new Point();
			pt.x = space + gap + col * (gap + len);
			pt.y = space + gap + row * (gap + len);
			return pt;
		}
		private function getRandomSquare():Square
		{
			var square:Square = borrowSquare();
			var pt:Point = squareMap.getAvailablePosition();
			if(!pt)
				return null;
			square.position = pt
			return square;
		}
		private function borrowSquare():Square
		{
			return ObjectPoolManager.getInstance().borrowItem(getQualifiedClassName(Square)) as Square;
		}
		private function returnSquare(square:Square):void
		{
			ObjectPoolManager.getInstance().returnItem(square);
		}
	}
}