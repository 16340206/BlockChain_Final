pragma solidity ^0.4.2;

contract Match{  

	address public organizer;					//组织者
	mapping (address => uint) public buyers;	//买票者持有票数
	uint public count;							//以售出票
	uint public price;  						//票价
	uint public capacity;						//场馆容量
	bool public stopsell;						//终止售票
	bool public soldout;   						//售票售罄 
	event Deposit(address _from, uint _amount); // 付款
	event Refund(address _to, uint _amount); 	// 退款

	function Match() public{		//构造函数
		organizer = msg.sender;		
		stopsell = false;
		soldout = false;
		price = 2 ether;
		capacity = 5;
		count = 0;
	}

	//买票函数
	function buyTickets (uint amount) public payable{
		// 票已售罄、买票超过上限、已停止售票、付款不够，退回已支付款项。
		if (soldout == true || count + amount > capacity 
		    || stopsell == true || msg.value < (price * amount)) {
		    msg.sender.transfer(msg.value);
		    return; 
		}

		if(msg.value >= (price * amount)) {
			buyers[msg.sender] += amount;		//持有票数增加
			count += amount;					//已售出票增加
			if(count == capacity) {				//判断票是否售罄
			    soldout = true;
			}
			Deposit(msg.sender, price * amount);

			//返还多余款项
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
			soldout = false;	//增加容量后存在多余票数
		}
	}
	//退票函数
	function refundTicket(uint amount) public payable{	
		msg.sender.transfer(msg.value);
	    if(stopsell == true) { return; }			//停止售票后不能再退款
	    uint temp = buyers[msg.sender];			
		if (temp >= amount) { 						//申请退票数量小于等于购票数量时才给予处理
			Refund(msg.sender, price * amount);	
			buyers[msg.sender] -= amount;			//持有票数减少
			count -= amount;						//售票总数减少
			soldout = false;						//存在多余票，没有售罄
			msg.sender.transfer(price * amount);	//退款
		}
		return;
	}


	function stopSell() public{
		if (msg.sender == organizer) {				// 停止售票
			stopsell = true;
			organizer.transfer(price * count);		//组织者获得实际收益
		}
	}
}
