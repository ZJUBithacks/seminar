# IBC  
  IBC（Inter-Blockchain Communication）协议是区块链间通信协议，用于两个独立共识算法的区块链间的严格顺序消息传递，类似于TCP/IP协议。使用IBC协议实现跨链，需要区块链满足：  
* 廉价快速可验证的 __最终性__（cheaply verifiable rapid finality）： 在共识算法的一些预定条件下，区块是不可逆的。如POW共识算法满足概率最终性，随着区块后面链接的区块越来越多，该区块被更改（推翻）的难度越大/可能性越小；tendermint的BFT算法则在区块出块之后能保证完全最终性，其更改区块需要>2/3的验证者串通。  
* Merkle树子状态证明  
  
在IBC协议中，为实现跨链通信，需要通信的两个区块链需要互相信任，建立连接，之后再进行跨链消息传输。由此，IBC主要分为两部分介绍：  
* 区块链间建立连接  
* 区块链间数据传输  
  
## 区块链间建立连接（connections）  
区块链间建立连接实际上是实现区块链间实现互信，具体来说就是区块链A能够及时获取另一区块链B的状态及共识规则集，使链A能够验证链B发来的数据包，以此确定该数据包已在链B执行。从另外一个角度来说，相当于链A和链B是各自的轻客户端。以共识算法均为tendermint的BPOS为例，链A和链B各自获得对方的最新区块的签名区块头和验证者集。  

### unbonding period  
为了使区块链之间及时获取最新的互信区块链状态，IBC设置了unbonding period，可认为是链A上存储链B的区块状态和共识规则与链B当前状态的最大窗口时间（另：在白皮书里将其描述为与当前最新区块之间的高度差），促使区块链及时更新相关信息，避免由于更新不及时遭受恶意链的攻击。例如：  
```
有链A当前最新高度A_h和链B当前最新高度B_h；
链A上存储了链B高度在B_hp的区块状态和共识规则，链B上存储了链A高度在A_hp的区块状态和共识规则；  
当B_hp与B_h的时间小于unbonding period，A_hp与A_h的时间小于unbonding period,链A和链B建立双向互信，可互相发送IBC数据包  
```  
由此，为了建立连接，结合unbonding period，区块链需向其他区块链提供以下证明：  
* 共识规则未变化：与最新区块时间差<unbonding period的高度上的签名区块头和共识规则子集以及相应 __更新__ 消息，可以此验证共识规则相同时，其他高度上的区块头；  
* 共识规则变化： 与最新区块时间差<unbonding period的高度上的签名区块头和共识规则子集以及相应 __更改__ 消息，可以此验证共识规则相同时，其他高度上的区块头；  
* 一个可信的签名区块头和相应merkle证明，以此证明在区块头里存储的对于key的值。  
  
## 区块链间数据传输  
在IBC，数据主要有两种消息类型`Packet`和`Receipt`。IBC消息的传输有严格的顺序，主要由区块链上的队列实现 __有序__ 的双向通信。两条相互通信的区块链A和B各自维护两个队列，分别为：  
* outgoing_A: 链A发送给链B的IBC数据包Packet，存储在链A上；  
* incoming_A: 针对链B发送的Packet的recipt，存储在链A上；  
* outgoing_B: 链B发送给链A的IBC数据包Packet，存储在链B上；  
* incoming_A: 针对链A发送的Packet的recipt，存储在链B上；  
  
实现从链A到链跨链通信的主要流程有：  
1. 将记录有目的地、发送地、序列、数据、类型的Packet加入到outgoing_A队列的末尾，进行发送；  
2. 链B接收到相应的Packet，验证消息（检查其目的地、发送地是否与Packet的记录一致、检查其相应区块头是否在可信区块头合集，利用merkle证明验证相应区块头）后，执行Packet，将执行结果与相关信息写入Receipt中，并将其加入incoming_B队列的末尾，发送到链A；  
3. 链A接收到相应的Recipt，验证消息（检查其目的地、发送地是否与Recipt的记录一致、检查其相应区块头是否在可信区块头合集，利用merkle证明验证相应区块头）后，将对应的消息从outgoing_A中删除。  
  
在跨链转账交易中，可将相应的转账金额进行托管，直到接收到recipt才能确认转账成功。如链A上的Alice需要将10ETH转给链B上的Bob，其主要过程有：  
1. 链A发送包含转账交易的Packet给链B，Alice账号上减去10ETH，10ETH被托管；  
2. 链B接收到相应的Packet，进行验证和执行，此时Bob的账号上加上10ETH，发送相应的Recipt给链A；  
3. 链A收到Recipt，进行验证，消息确认成功，托管的10ETH已确认转账。  
  
如果在链B上Packet验证执行不成功，那么链A收到相应的Recipt之后会将托管的10ETH重新转给Alice，转账交易失败。  
由以上可知，跨链通信流程比较简单。通过队列和消息中的序列进行有序双向通信。  
# Refs  
[1]. https://github.com/cosmos/cosmos-sdk/tree/develop/docs/spec/ibc  
[2]. https://www.itcodemonkey.com/article/8420.html
  


