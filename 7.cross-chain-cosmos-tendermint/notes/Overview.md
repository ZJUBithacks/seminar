# Overview
Cosmos是由许多独立区块链组成的区块链网络。网络中的第一条区块链是Cosmos Hub，其他区块链被称为Zone（分区）。Hub与分区Zone之间通过IBC协议进行通信。对于无法兼容IBC协议的区块链，cosmos也提出了Peg Zone，将其作为中继，实现cosmos网络与无法兼容IBC协议区块链的通信。其cosmos网络示意图如下：    
<div align=center>  
  <img width="800" height="480" src="./pictures/cosmos%E7%BD%91%E7%BB%9C%E7%A4%BA%E6%84%8F%E5%9B%BE.jpg"/>  
</div>  

其中，Hub具有的功能有：  
* 可通过区块链间通信（IBC）协议与Zone进行通信  
* 负责记录每个分区的代币总数，进行跨区代币转移  
* 可通过链接其他分区来实现扩展  
* 可将其他分区与故障分区隔离  
* 采用多代币模型，将权益代币与费用代币进行分离，接受多种交易代币
  
而作为独立的区块链，Zone也具有：  
* 具有独立的共识算法  
* 根据每个Zone的价值和利益维护主权  
* 可通过hub与其他Zone进行通信
  
Peg Zone实现了Hub与不兼容IBC协议区块链间的通信，目前还未开发完成。到目前为止，其特点有：  
* 维护区块链用户信息、实现跨链交易、交易查询  
* 通过IBC协议与Hub进行通信  
* 通过witness对区块链进行监听  
* 通过relayer进行交易转发

为了构建cosmos网络，cosmos团队提供了Cosmos-sdk和tendermint框架，其架构示意图为：  
 
<div align= center>  
  <img width="400" height="400" src="./pictures/cosmos%E8%8A%82%E7%82%B9%E7%A4%BA%E6%84%8F%E5%9B%BE.jpg"/>  
</div>  
  
由上图可知，cosmos-sdk是cosmos区块链的开发框架，为区块链开发者提供通用的功能模块，如ibc（跨链通信）、staking（抵押）、governance（治理）等。  
而tendermint则是提供了底层的共识和网络。Tendermint采用BPOS（Bonded Proof Of Stake）算法，其主要特点有：  
* 通过抵押代币成为验证者，其投票权大小与抵押代币数目相关  
* 验证者轮流进行打包出块，其被选中成为出块者的频率与抵押权益正相关  
* 锁定机制和锁变化证明PoLC保证区块链具有强一致性，不会出现分叉  
  
Tendermint通过ABCI接口（Application BlockChain Interface）与区块链应用进行通信。所有消息类型都在protobuf文件中定义，这使开发者可以使用任何编程语言编写应用程序。  
下面将从以下几个方面对Cosmos和Tendermint进行详细介绍：  
1. [多代币模型](./mutli-token%20model.md)：  
* 权益代币与费用代币分离  
* 原生代币：Atom和Proton  
* 交易奖励分配  
  
2. [Tendermint简介](./Tendermint.md)：  
* 数据结构：Block、State  
* Tendermint Core:  
  - 共识算法BPOS：验证者、选定出块者、共识过程：锁定机制和PoLC...  
  - 网络：RPC协议、P2P协议  
* ABCI：三个ABCI连接  
  
3. [IBC简介](./IBC.md)：  
* 建立连接  
* 数据传输  
  
## Refs：  
[1]. https://github.com/cosmos/cosmos-sdk/tree/develop/docs  
[2]. https://cosmos.network/  
[3]. https://raw.githubusercontent.com/cosmos/cosmos/master/Cosmos_Token_Model.pdf  
[4]. https://github.com/cosmos/cosmos/blob/master/WHITEPAPER.md  
[5]. https://mp.weixin.qq.com/s?__biz=MzUyMjg0MzIxMA==&mid=2247483679&idx=1&sn=1fadfa95a266e199c3f2966c2decfbae&chksm=f9c4e43aceb36d2c19f07450f98a2938ef345aeb454f0f668057e66a89adb0dfda91910cccd9&scene=21#wechat_redirect  
[6]. https://www.itcodemonkey.com/article/8420.html
