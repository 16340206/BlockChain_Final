pragma solidity ^0.4.2;

contract Match{  

	address public organizer;	//组织者
	mapping (address => uint) public buyers;	//买票者们
	uint public count;	//买票人数
	uint public price;  
	uint public capacity;	//场馆容量
	bool public stopsell;	//终止售票
	bool public soldout;   //票售罄 
	event Deposit(address _from, uint _amount); // 付款
	event Refund(address _to, uint _amount); // 退款

	function Match() public{	//构造函数
		organizer = msg.sender;		
		stopsell = false;
		soldout = false;
		price = 2 ether;
		capacity = 5;
		count = 0;
	}

	function buyTickets (uint amount) public payable{
		if (soldout == true || count + amount > capacity 
		    || stopsell == true || msg.value < (price * amount)) {
		    msg.sender.transfer(msg.value);
		    return; 
		}
		if(msg.value >= (price * amount)) {
			buyers[msg.sender] += amount;
			count += amount;
			if(count == capacity) {
			    soldout = true;
			}
			Deposit(msg.sender, price * amount);
			uint refundFee = msg.value - price * amount;
			if(refundFee > 0) {
				msg.sender.transfer(refundFee);
			}
		}


	}

	function increaseCapacity(uint add) public {	//临时增加场馆容量
		if (msg.sender != organizer) { return; }
		if(add > 0) {
			capacity += add;
			soldout = false;
		}
	}



	function refundTicket(uint amount) public payable{	//退票
		msg.sender.transfer(msg.value);
	    if(stopsell == true) { return; }
	    uint temp = buyers[msg.sender];
		if (temp >= amount) { 
			Refund(msg.sender, price * amount);
			buyers[msg.sender] -= amount;
			count -= amount;
			soldout = false;
			msg.sender.transfer(price * amount);
		}
		return;
	}

	/*	哥写报告的时候直接删了吧
	//	理论上不应该存在这个函数，发布者可以携款而逃，并且再次执行程序引出各种错误，
	// 	在实际运行中添加这个函数就是犯规的，
	//	但在测试阶段，执行stopSell之后合约就不能再运行
	//	每次都要需要重新部署实在是非常麻烦，所以存在这么一个函数。
	function OverTime() public {				
	    if (msg.sender == organizer) {
	        stopsell = false;
	    }
	}
	*/

	function stopSell() public{
		if (msg.sender == organizer) { // 停止售票
			stopsell = true;
			organizer.transfer(price * count);
		}
	}
}
