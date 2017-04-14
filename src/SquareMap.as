package
{
	import flash.geom.Point;

	public class SquareMap
	{
		public var map:Array;
		private var row:int;
		private var col:int;
		
		public var anyChange:Boolean = true;
		
		public function SquareMap(row:int, col:int)
		{
			this.row = row;
			this.col = col;
			resetMap();
		}
		public function resetMap():void
		{
			map = [];
			for (var i:int = 0; i < row; i++) 
			{
				var temp:Array = [];
				for (var j:int = 0; j < col; j++) 
				{
					temp.push(null);
				}
				map.push(temp);
			}
		}
		public function getAvailablePosition():Point
		{
			if(!anyChange)
				return null;
			var pt:Point = new Point();
			do 
			{
				pt.x = int(Math.random() * col);
				pt.y = int(Math.random() * row);
			} while(map[pt.y][pt.x]);
			return pt;
		}
		public function moveSquares(direction:int):int
		{
			var score:int = 0;
			var temp:int;
			var getFunc:Function;
			var limit:int;
			var att:String;
			anyChange = false;
			if(direction < 3)
			{
				temp = col;
				getFunc = getSquareByCol;
				att = "y";
				limit = direction == 1 ? 0 : row - 1;
			}
			else
			{
				temp = row;
				getFunc = getSquareByRow;
				att = "x";
				limit = direction == 3 ? 0 : col - 1;
			}
			
			for (var i:int = 0; i < temp; i++) 
			{
				var arr:Array = getFunc(i, direction % 2);
				for (var j:int = 1; j < arr.length; j++) 
				{
					if(arr[j] == null)
						continue;
					for (var k:int = j - 1; k > -1; k--) 
						if(arr[k] && arr[k].isRemoved == false)
							break;
					if(k < 0)
					{
						arr[j].position[att] = limit;
						anyChange = true;
					}
					else
					{
						if(arr[k].isMegered || arr[k].num != arr[j].num)
						{
							var newAtt:int = arr[k].position[att] + (direction % 2 ? 1 : -1);
							if(arr[j].position[att] != newAtt)
							{
								anyChange = true;
								arr[j].position[att] = newAtt;
							}
						}
						else if(arr[k].num == arr[j].num)
						{
							arr[j].isRemoved = true;
							arr[j].position = arr[k].position;
							arr[k].isMegered = true;
							arr[k].num *= 2;
							anyChange = true;
							score ++;
						}
					}
				}
			}
			
			return score;
		}
		
		public function updateSquares():void
		{
			for (var i:int = 0; i < row; i++) 
				for (var j:int = 0; j < col; j++) 
					if(map[i][j] && map[i][j].isRemoved == false)
						map[i][j].update();
		}
		public function checkAlive():Boolean
		{
			for (var i:int = 0; i < row; i++) 
				for (var j:int = 0; j < col; j++) 
					if(map[i][j] == null)
						return true;
			for(i = 0 ; i < row ; i ++)
				for(j = 0 ; j < col ; j ++)
				{
					if(i < row - 1)
					{
						if(map[i][j].num == map[i + 1][j].num)
							return true;
					}
					if(j < col - 1)
					{
						if(map[i][j].num == map[i][j + 1].num)
							return true;
					}
				}
			
			return false;
		}
		public function setSquare(square:Square):void
		{
			map[square.position.y][square.position.x] = square;
		}
		/**
		 * 
		 * @param row
		 * @param direction 非0表示从右往左 ；0表示从左往右
		 * @return 
		 * 
		 */		
		public function getSquareByRow(row:int, direction:int):Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < map[row].length; i++) 
			{
				arr.push(map[row][i]);
			}
			
			if(direction)
				return arr;
			else
				return arr.reverse();
		}
		/**
		 *  
		 * @param col
		 * @param direction 非0表示从上往下，0表示从下往上
		 * @return 
		 * 
		 */		
		public function getSquareByCol(col:int, direction:int):Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < row; i++) 
			{
				arr.push(map[i][col]);
			}
			if(direction)
				return arr;
			else
				return arr.reverse();
		}
		public function getAllSquares():Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < map.length; i++) 
				for (var j:int = 0; j < map[i].length; j++)
					if(map[i][j])
						arr.push(map[i][j]);
			return arr;
		}
	}
}